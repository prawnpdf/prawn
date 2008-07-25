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

# Head is the font header table, which gives global informations about the font.
class Head < Font::TTF::FontChunk

    LONG_FORMAT = 1
    SHORT_FORMAT = 0

    attr_accessor :version, :font_revision, :check_sum_adjustment, 
                  :magic_number, :flags, :units_per_em, :created, 
                  :modified, :x_min, :y_min, :x_max, :y_max, :mac_style, 
                  :lowest_rec_ppem, :font_direction_hint, 
                  :index_to_loc_format, :glyph_data_format

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @version = @font.read_fixed
                @font_revision = @font.read_fixed
                @check_sum_adjustment = @font.read_ulong
                @magic_number = @font.read_ulong
                @flags = @font.read_ushort
                @units_per_em = @font.read_ushort
                @created = @font.read_long_date_time
                @modified = @font.read_long_date_time
                @x_min = @font.read_fword
                @y_min = @font.read_fword
                @x_max = @font.read_fword
                @y_max = @font.read_fword
                @mac_style = @font.read_ushort
                @lowest_rec_ppem = @font.read_ushort
                @font_direction_hint = @font.read_short
                @index_to_loc_format = @font.read_short
                @glyph_data_format = @font.read_short
            end
        end
    end

    # Dumps the head table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@version || 0).to_fixed
        raw += (@font_revision || 0).to_fixed
        raw += (@check_sum_adjustment || 0).to_ulong
        raw += (@magic_number || 0).to_ulong
        raw += (@flags || 0).to_ushort
        raw += (@units_per_em || 0).to_ushort
        raw += (@created || "").to_long_date_time
        raw += (@modified || "").to_long_date_time
        raw += (@x_min || 0).to_fword
        raw += (@y_min || 0).to_fword
        raw += (@x_max || 0).to_fword
        raw += (@y_max || 0).to_fword
        raw += (@mac_style || 0).to_ushort
        raw += (@lowest_rec_ppem || 0).to_ushort
        raw += (@font_direction_hint || 0).to_short
        raw += (@index_to_loc_format || 0).to_short
        raw += (@glyph_data_format || 0).to_short
    end
    
end

end
end
end