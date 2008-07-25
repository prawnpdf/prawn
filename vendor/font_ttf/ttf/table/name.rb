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

require 'iconv'

module Font
module TTF
module Table

# Name is the the Naming table which allows multilingual strings to be
# associated with the TrueType font file.
class Name < Font::TTF::FontChunk

    # A NameRecord holds a string for a given Platform and Encoding.
    class NameRecord < Font::TTF::FontChunk
        include Font::TTF::Encodings

        COPYRIGHT_NOTICE = 0
        FONT_FAMILY_NAME = 1
        FONT_SUBFAMILY_NAME = 2
        UNIQUE_FONT_IDENTIFIER = 3
        FULL_FONT_NAME = 4
        VERSION_STRING = 5
        POSTSCRIPT_NAME = 6
        TRADEMARK = 7
        MANUFACTURER_NAME = 8
        DESIGNER_NAME = 9
        DESCRIPTION = 10
        VENDOR_URL = 11
        DESIGNER_URL = 12
        LICENSE_DESCRIPTION = 13
        LICENSE_URL = 14
        RESERVED = 15
        PREFERRED_FAMILY = 16
        PREFERRED_SUBFAMILY = 17
        COMPATIBLE_FULL = 18

        ID2NAME = {
            COPYRIGHT_NOTICE => "Copyright Notice",
            FONT_FAMILY_NAME => "Font Family Name",
            FONT_SUBFAMILY_NAME => "Font Subfamily Name",
            UNIQUE_FONT_IDENTIFIER => "Unique Font Identifier",
            FULL_FONT_NAME => "Full Font Name",
            VERSION_STRING => "Version String",
            POSTSCRIPT_NAME => "Postscript Name",
            TRADEMARK => "Trademark",
            MANUFACTURER_NAME => "Manufacturer Name",
            DESIGNER_NAME => "Designer Name",
            DESCRIPTION => "Description",
            VENDOR_URL => "Vendor URL",
            DESIGNER_URL => "Designer URL",
            LICENSE_DESCRIPTION => "License Description",
            LICENSE_URL => "License URL",
            RESERVED => "Reserved",
            PREFERRED_FAMILY => "Preferred Family",
            PREFERRED_SUBFAMILY => "Preferred Subfamily",
            COMPATIBLE_FULL => "Compatible full"
        }

      
        SIZEOF_NAME_RECORD = 6 * IO::SIZEOF_USHORT

        attr_accessor :platform_id, :encoding_id, :language_id, :name_id, 
                      :str_offset, :str

        def initialize(table, n=nil)
            @table = table

            if n.nil?
                # New name record created by hand
                super(@table.font)
                @platform_id = @table.font.read_ushort
                @encoding_id = @table.font.read_ushort
                @language_id = 0
            else
                offset = @table.offset + 3 * IO::SIZEOF_USHORT + \
                        n * SIZEOF_NAME_RECORD
    
                super(@table.font, offset, SIZEOF_NAME_RECORD)
    
                @table.font.at_offset(@offset) do
                    @platform_id = @table.font.read_ushort
                    @encoding_id = @table.font.read_ushort
                    @language_id = @table.font.read_ushort
                    @name_id = @table.font.read_ushort
                    @str_len = @table.font.read_ushort
                    @str_offset = @table.font.read_ushort
                end
    
                offs = @table.offset + @table.string_storage_offset + \
                       @str_offset
                @table.font.at_offset(offs) do
                    @str = @table.font.read(@str_len)
                end
            end
        end

        # Returns string "as is".
        def to_s
            @str
        end

        # Returns whether the string is Macintosh Roman or not.
        def roman?
            @platform_id == Platform::MACINTOSH and \
            @encoding_id == MacintoshEncoding::ROMAN
        end

        # Returns whether the string is unicode or not.
        def unicode?
            @platform_id == Platform::UNICODE or \
            (@platform_id == Platform::MICROSOFT and \
            @encoding_id == MicrosoftEncoding::UNICODE)
        end

        # Returns the string in UTF-8 if possible.
        def utf8_str
            if unicode?
                # from utf-16 big endian to utf-8
                Iconv.new("utf-8", "utf-16be").iconv(@str)
            else
                @str
            end
        end

        # Sets the NameRecord string with new_string being UTF-8.
        def utf8_str=(new_string)
            if unicode?
                # from utf-8 to utf-16 big endian
                @str = Iconv.new("utf-16be", "utf-8").iconv(new_string)
            else
                @str = new_string
            end
        end

        def dump
            # Dump everything except str_offset, which can't be calculated
            # here and the string itself which must be put in the storage
            # area
            raw = (@platform_id || Platform::MACINTOSH).to_ushort
            raw += (@encoding_id || MacintoshEncoding::ROMAN).to_ushort
            raw += (@language_id || 0).to_ushort
            raw += (@name_id || 0).to_ushort
            raw += (@str.length || 0).to_ushort
        end

    end

    attr_accessor :format_selector
    # An Array of NameRecord objects.
    attr_accessor :name_records
    attr_reader :string_storage_offset

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @format_selector = @font.read_ushort
                @name_record_num = @font.read_ushort
                @string_storage_offset = @font.read_ushort
            end

            @name_records = []
            @name_record_num.times do |i|
                @name_records << NameRecord.new(self, i)
            end
        end
    end

    # Gets a new empty NameRecord which may then be added to the 
    # name_records array.
    def get_new_name_record
        NameRecord.new(self)
    end

    # Dumps the name table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@format_selector || 0).to_ushort

        nr_num = @name_records.length || 0
        raw += nr_num.to_ushort

        string_storage_offset = 3 * IO::SIZEOF_USHORT + \
                                nr_num * NameRecord::SIZEOF_NAME_RECORD
        raw += string_storage_offset.to_ushort

        str_offset = 0 # starting from string_storage_offset
        strs = []
        @name_records.each do |nr|
            raw += nr.dump
            raw += str_offset.to_ushort
            str_offset += nr.str.length
            strs << nr.str
        end

        strs.each do |str|
            raw += str
        end
        raw
    end
   
end

end
end
end