# TTF/Ruby, a library to read and write TrueType fonts in Ruby.
# Copyright (C) 2006  Mathieu Blondel
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

module Font
module TTF
module Table

# Cmap is the character to glyph index mapping table.
class Cmap < Font::TTF::FontChunk

    # Base class for encoding table classes. It provides attributes which are
    # common to those classes such as platform_id and encoding_id.
    class EncodingTable < Font::TTF::FontChunk

        attr_accessor :table, :platform_id, :encoding_id, :offset_from_table  
        
        def initialize(table, offset=nil, len=nil, platform_id=nil,
                       encoding_id=nil)
            @table = table
            @font = table.font
            
            if not offset.nil?
                @offset_from_table = offset
                @platform_id = platform_id
                @encoding_id = encoding_id
                super(@table.font, @table.offset + offset, len)
            else
                super(@table.font)
            end
        end

        def unicode?
            @platform_id == Font::TTF::Encodings::Platform::UNICODE or \
            (@platform_id == Font::TTF::Encodings::Platform::MICROSOFT and \
            @encoding_id == Font::TTF::Encodings::MicrosoftEncoding::UNICODE)
        end

        # Returns the format (a Fixnum) of the encoding table.
        def format
            if self.class.superclass == EncodingTable
                self.class.name.split(//).last.to_i
            else
                nil # Not implemented table format
            end
        end

    end

    # Encoding table in format 0, the Apple standard character to glyph
    # mapping table.
    class EncodingTable0 < EncodingTable

        attr_accessor :version
        # An array of 256 elements with simple one to one mapping of
        # character codes to glyph indices.
        #
        # Char 0 => Index glyph_id_array[0]
        # Char 1 => Index glyph_id_array[1]
        # ...
        attr_accessor :glyph_id_array

        def initialize(*args) 
            super(*args)          
            if exists_in_file?
                # 2 * IO::SIZEOF_USHORT corresponds to format and len
                # that we want to skip
                @table.font.at_offset(@offset + 2 * IO::SIZEOF_USHORT) do
                    @version = @font.read_ushort
                    @glyph_id_array = @font.read_bytes(256)
                end
            else
                # This is to ensure that it will be an array
                @glyph_id_array = []
            end
        end

        # Dumps the table in binary raw format as may be found in a font
        # file.
        def dump
            raw = (format || 0).to_ushort
            len = 3 * IO::SIZEOF_USHORT + 256
            raw += len.to_ushort
            raw += (@version || 0).to_ushort
            raw += @glyph_id_array.to_bytes
        end
    end

    # Encoding table in format 2. Not implemented.
    class EncodingTable2 < EncodingTable
    end

    # Encoding table in format 4. This format is well-suited to map
    # several contiguous ranges, possibly with holes of characters.
    class EncodingTable4 < EncodingTable

        attr_accessor :version

        attr_reader :search_range, :entry_selector, :range_shift, 
                    :end_count_array, :reserved_pad, :start_count_array, 
                    :id_delta_array, :id_range_offset_array, 
                    :glyph_index_array, :segments

        def initialize(*args)
            super(*args)

            if exists_in_file?                
                # 2 * IO::SIZEOF_USHORT corresponds to format and len
                # that we want to skip
                @table.font.at_offset(@offset + 2 * IO::SIZEOF_USHORT) do
                    @version = @font.read_ushort
                    @seg_count_x2 = @font.read_ushort
                    @seg_count = @seg_count_x2 / 2
                    @search_range = @font.read_ushort
                    @entry_selector = @font.read_ushort
                    @range_shift = @font.read_ushort
                    @end_count_array = @font.read_ushorts(@seg_count)
                    @reserved_pad = @font.read_ushort
                    @start_count_array = @font.read_ushorts(@seg_count)
                    @id_delta_array = @font.read_ushorts(@seg_count)
                    @id_range_offset_array = @font.read_ushorts(@seg_count)

                    @nb_glyph_indices = len - 8 * IO::SIZEOF_USHORT \
                                          - 4 * @seg_count * IO::SIZEOF_USHORT
                    @nb_glyph_indices /= IO::SIZEOF_USHORT;

                    if @nb_glyph_indices > 0
                        @glyph_index_array = \
                            @font.read_ushorts(@nb_glyph_indices)
                    else
                        @glyph_index_array = []
                    end 
                    
                    # Keep them in memory so we don't need to
                    # recalculate them every time
                    @segments = get_segments
                end # end at_offset
            else
                @segments = []
                @glyph_index_array = []
            end
        end # end initialize

        def get_segments
            segments = []

            # For each segment...
            @start_count_array.each_with_index do |start, curr_seg|
                endd = @end_count_array[curr_seg]
                delta = @id_delta_array[curr_seg]
                range = @id_range_offset_array[curr_seg]
    
                segments[curr_seg] = {}

                start.upto(endd) do |curr_char|
                    if range == 0
                        index = (curr_char + delta)                    
                    else
                        gindex = range / 2 + (curr_char - start) - \
                                (@seg_count - curr_seg)
                        index = @glyph_index_array[gindex]
                        index = 0 if index.nil?
                        index += delta if index != 0
                    end
                    index = index % 65536
                    # charcode => glyph index
                    segments[curr_seg][curr_char] = index
                end
            end
            segments
        end
        private :get_segments

        # Returns a Hash. Its keys are characters codes and associated values
        # are glyph indices.
        def charmaps
            hsh = {}
            segments.each do |seg| 
                seg.each do |char_code, glyph_index|
                    hsh[char_code] = glyph_index
                end
            end
            hsh
        end

        # Sets the charmaps. cmps is a Hash in the same fashion as the one
        # returned by charmaps.
        def charmaps=(cmps)
            # TODO: we would need fewer segments if we ensured that
            # glyphs with id in ascending order were associated
            # with char codes in ascending order
            raise "Charmaps is an empty array" if cmps.length == 0

            # Order is important since we will rebuild segments           
            char_codes = cmps.keys.sort

            @start_count_array = []
            @end_count_array = []
            @id_delta_array = []
            curr_seg = 0
            i = 0

            @start_count_array[0] = char_codes.first
            @id_delta_array[0] = cmps[char_codes.first] - char_codes.first

            last_char = 0
            char_codes.each do |char_code|
                glyph_id = cmps[char_code]
                curr_delta = glyph_id - char_code                 
                if i > 0 and curr_delta != @id_delta_array.last
                    # Need to create a new segment
                    @end_count_array[curr_seg] = last_char
                    curr_seg += 1
                    @start_count_array[curr_seg] = char_code
                    @id_delta_array[curr_seg] = curr_delta
                end        
                last_char = char_code
                i += 1
            end
            seg_count = @start_count_array.length
            @end_count_array[seg_count - 1] = last_char
            @id_range_offset_array = [0] * seg_count # Range offsets not used
            @segments = get_segments # Recalculate segments

            # Values below are calculated
            # to allow faster computation by font rasterizers
            res = 1
            power = 0
            while res <= seg_count
                res *= 2
                power += 1
            end
            @search_range = res
            @entry_selector = power - 1
            @range_shift = 2 * seg_count - @search_range       
        end

        # Returns index/id of glyph associated with unicode.
        def get_glyph_id_for_unicode(unicode)
            id = 0
            @segments.length.times do |i|
                if @start_count_array[i] <= unicode and \
                   unicode <= @end_count_array[i]
                    @segments[i].each do |char_code, glyph_id|
                        if char_code == unicode
                            id = glyph_id
                            break
                        end
                    end
                end
            end
            id
        end

        # Returns the Font::TTF::Table::Glyf::SimpleGlyph or 
        # Font::TTF::Table::Glyf::CompositeGlyph associated with unicode.
        def get_glyph_for_unicode(unicode)
            id = get_glyph_id_for_unicode(unicode)
            offs = @font.get_table(:loca).glyph_offsets[id]
            @font.get_table(:glyf).get_glyph_at_offset(offs)
        end

        # Returns the unicode of glyph with index id.
        def get_unicode_for_glyph_id(id)
            # TODO: this method could be rewritten much more efficiently
            # by using @start_count_array and @end_count_array
            unicode = 0
            charmaps.each do |char_code, glyph_index|                
                if glyph_index == id
                    unicode = char_code 
                    break
                end
            end
            unicode             
        end
    
        # Dumps the table in binary raw format as may be found in a font
        # file.
        def dump
            raw = (format || 0).to_ushort
            seg_count = @segments.length || 0
            len = 8 * IO::SIZEOF_USHORT + 4 * seg_count * IO::SIZEOF_USHORT + \
                  @glyph_index_array.length * IO::SIZEOF_USHORT
            raw += len.to_ushort
            raw += (@version || 0).to_ushort
            raw += (seg_count * 2).to_ushort
            raw += (@search_range || 0).to_ushort
            raw += (@entry_selector || 0).to_ushort
            raw += (@range_shift || 0).to_ushort
            raw += (@end_count_array || []).to_ushorts
            raw += (@reserved_pad || 0).to_ushort
            raw += (@start_count_array || []).to_ushorts
            raw += (@id_delta_array || []).to_ushorts
            raw += (@id_range_offset_array || []).to_ushorts
            raw += (@glyph_index_array || []).to_ushorts
        end
    end

    # Encoding table in format 6. Not implemented.
    class EncodingTable6 < EncodingTable
    end

    # Encoding table in format 8. Not implemented.
    class EncodingTable8 < EncodingTable
    end

    # Encoding table in format 10. Not implemented.
    class EncodingTable10 < EncodingTable
    end

    # Encoding table in format 12. Not implemented.
    class EncodingTable12 < EncodingTable
    end

    attr_accessor :version
    # An Array of encoding_tables. You may add or remove encoding tables
    # from this array.
    attr_accessor :encoding_tables

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @version = @font.read_ushort
                @encoding_table_num = @font.read_ushort
                @encoding_tables = []
                @encoding_table_num.times do
                    platform_id = @font.read_ushort
                    encoding_id = @font.read_ushort
                    offset = @font.read_ulong
                
                    @font.at_offset(@offset + offset) do
                        format = @font.read_ushort
                        len = @font.read_ushort

                        if [0, 2, 4, 6, 8, 10, 12].include? format
                            klass = eval("EncodingTable%d" % format)
                        else
                            klass = EncodingTable
                        end

                        @encoding_tables << klass.new(self, 
                                                      offset,
                                                      len,        
                                                      platform_id,
                                                      encoding_id)
                    end
                end
                
            end        
        else
            @encoding_tables = []
        end
    end

    # Returns a new empty EncodingTable0 object that you may add to the
    # encoding_tables array.
    def get_new_encoding_table0
        EncodingTable0.new(self)
    end

    # Returns a new empty EncodingTable4 object that you may add to the
    # encoding_tables array.
    def get_new_encoding_table4
        EncodingTable4.new(self)
    end

    # Dumps the cmap table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@version || 0).to_ushort
        raw += (@encoding_tables.length || 0).to_ushort
        dumps = []
        offs = 2 * IO::SIZEOF_USHORT + @encoding_tables.length * \
                (2 * IO::SIZEOF_USHORT + IO::SIZEOF_ULONG)
        @encoding_tables.each do |enc_tbl|
            raw += (enc_tbl.platform_id || 3).to_ushort
            raw += (enc_tbl.encoding_id || 1).to_ushort
            dump = enc_tbl.dump
            dumps << dump
            raw += offs.to_ulong
            offs += dump.length
        end
        dumps.each do |dump|
            raw += dump
        end
        raw
    end

end

end
end
end