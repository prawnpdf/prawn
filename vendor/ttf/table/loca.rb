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

# Loca is the Location table class. It provides the offsets of glyphs in
# the glyf table.
class Loca < Font::TTF::FontChunk

    # An array of glyphs offsets with number of glyphs + 1 elements.
    # The value associated with a given index of that array
    # is the offset associated with glyph with index index.
    # This offset may be used with Font::TTF::Table::Glyf#get_glyph_at_offset
    # to get the glyph object associated with offset.
    #
    # The additional offset is added so that the length of the
    # last glyph can be calculated: 
    # len of last glyph = additional offs - last glyph offs
    attr_accessor :glyph_offsets

    # It is not recommended to create Loca objects by hand.
    # Use Font::TTF::File#get_table or Font::TTF::File#get_new_table
    # with :loca as parameter instead.
    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                n = @font.get_table(:maxp).num_glyphs + 1

                case @font.get_table(:head).index_to_loc_format
                    when Font::TTF::Table::Head::SHORT_FORMAT
                        @glyph_offsets = @font.read_ushorts(n)
                        @glyph_offsets.collect! { |o| o * 2 }
                    when Font::TTF::Table::Head::LONG_FORMAT
                        @glyph_offsets = @font.read_ulongs(n)

                end
            end
        end
    end

    # Dumps the loca table in binary raw format as may be found in a font
    # file.
    def dump
        case @font.get_table(:head).index_to_loc_format
            when Font::TTF::Table::Head::SHORT_FORMAT
                @glyph_offsets.collect { |o| o / 2 }.to_ushorts
            when Font::TTF::Table::Head::LONG_FORMAT
                @glyph_offsets.to_ulongs

        end
    end
    
end

end
end
end