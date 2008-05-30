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

# OS2 is the OS/2 and Windows font metrics table.
class OS2 < Font::TTF::FontChunk

    INSTALLABLE_EMBEDDING = 0x0000
    RESTRICTED_LICENCE_EMBEDDING = 0x0002
    PREVIEW_AND_PRINT_EMBEDDING = 0x0004
    EDITABLE_EMBEDDING = 0x0008
    NO_SUBSET_EMBEDDING = 0x0100
    BITMAP_ONLY_EMBEDDING = 0x0200
    

    attr_accessor :version, :x_avg_char_width, :us_weight_class,
                  :us_width_class, :fs_type, :y_subscriptXSize,
                  :y_subscript_y_size, :y_subscript_x_offset,
                  :y_subscript_y_offset, :y_superscript_x_size,
                  :y_superscript_y_size, :y_superscript_x_offset,
                  :y_superscript_y_offset, :y_strikeout_size,
                  :y_strikeout_position, :s_family_class,
                  :panose, :ul_unicode_range1, :ul_unicode_range2,
                  :ul_unicode_range3, :ul_unicode_range4, 
                  :ach_vend_id, :fs_selection, :us_first_char_index,
                  :us_last_char_index, :s_typo_ascender, :s_typo_descender,
                  :s_typo_line_gap, :us_win_ascent, :us_win_descent,
                  :ul_code_page_range1, :ul_code_page_range2,
                  :sx_height, :s_cap_height, :us_default_char,
                  :us_break_char, :us_max_context

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @version = @font.read_ushort
                @x_avg_char_width = @font.read_short
                @us_weight_class = @font.read_ushort
                @us_width_class = @font.read_ushort
                @fs_type = @font.read_short
                @y_subscriptXSize = @font.read_short
                @y_subscript_y_size = @font.read_short
                @y_subscript_x_offset = @font.read_short
                @y_subscript_y_offset = @font.read_short
                @y_superscript_x_size = @font.read_short
                @y_superscript_y_size = @font.read_short
                @y_superscript_x_offset = @font.read_short
                @y_superscript_y_offset = @font.read_short
                @y_strikeout_size = @font.read_short
                @y_strikeout_position = @font.read_short
                @s_family_class = @font.read_short
                @panose = @font.read_bytes(10)
                @ul_unicode_range1 = @font.read_ulong
                @ul_unicode_range2 = @font.read_ulong
                @ul_unicode_range3 = @font.read_ulong
                @ul_unicode_range4 = @font.read_ulong
                @ach_vend_id = @font.read_chars(4)
                @fs_selection = @font.read_ushort
                @us_first_char_index = @font.read_ushort
                @us_last_char_index = @font.read_ushort
                @s_typo_ascender = @font.read_short
                @s_typo_descender = @font.read_short
                @s_typo_line_gap = @font.read_short
                @us_win_ascent = @font.read_ushort
                @us_win_descent = @font.read_ushort
                @ul_code_page_range1 = @font.read_ulong
                @ul_code_page_range2 = @font.read_ulong
                # From opentype spec
                @sx_height = @font.read_short
                @s_cap_height = @font.read_short
                @us_default_char = @font.read_ushort
                @us_break_char = @font.read_ushort
                @us_max_context = @font.read_ushort
            end
        end
    end

    def installable_embedding?
        @fs_type == INSTALLABLE_EMBEDDING
    end

    def editable_embedding?
        installable_embedding? or @fs_type & EDITABLE_EMBEDDING != 0
    end

    def preview_and_print_embedding?
        editable_embedding? or @fs_type & PREVIEW_AND_PRINT_EMBEDDING != 0
    end

    def restricted_licence_embedding?
        (not preview_and_print_embedding? and 
            @fs_type & RESTRICTED_LICENCE_EMBEDDING != 0)
    end

    def no_subset_embedding?
        @fs_type & NO_SUBSET_EMBEDDING != 0
    end

    def subset_embedding?
        not no_subset_embedding?
    end

    def bitmap_only_embedding?
        @fs_type & BITMAP_ONLY_EMBEDDING != 0
    end
    
    # Dumps the os2 table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@version || 0).to_ushort
        raw += (@x_avg_char_width || 0).to_short
        raw += (@us_weight_class || 0).to_ushort
        raw += (@us_width_class || 0).to_ushort
        raw += (@fs_type || 0).to_ushort
        raw += (@y_subscriptXSize || 0).to_short
        raw += (@y_subscript_y_size || 0).to_short
        raw += (@y_subscript_x_offset || 0).to_short
        raw += (@y_subscript_y_offset || 0).to_short
        raw += (@y_superscript_x_size || 0).to_short
        raw += (@y_superscript_y_size || 0).to_short
        raw += (@y_superscript_x_offset || 0).to_short
        raw += (@y_superscript_y_offset || 0).to_short
        raw += (@y_strikeout_size || 0).to_short
        raw += (@y_strikeout_position || 0).to_short
        raw += (@s_family_class || 0).to_short
        raw += (@panose || [0] * 10).to_bytes
        raw += (@ul_unicode_range1 || 0).to_ulong
        raw += (@ul_unicode_range2 || 0).to_ulong
        raw += (@ul_unicode_range3 || 0).to_ulong
        raw += (@ul_unicode_range4 || 0).to_ulong
        raw += (@ach_vend_id || " " * 4)
        raw += (@fs_selection || 0).to_ushort
        raw += (@us_first_char_index || 0).to_ushort
        raw += (@us_last_char_index || 0).to_ushort
        raw += (@s_typo_ascender || 0).to_short
        raw += (@s_typo_descender || 0).to_short
        raw += (@s_typo_line_gap || 0).to_short
        raw += (@us_win_ascent || 0).to_ushort
        raw += (@us_win_descent || 0).to_ushort
        raw += (@ul_code_page_range1 || 0).to_ulong
        raw += (@ul_code_page_range2 || 0).to_ulong
        # From opentype spec
        raw += (@sx_height || 0).to_short
        raw += (@s_cap_height || 0).to_short
        raw += (@us_default_char || 0).to_ushort
        raw += (@us_break_char || 0).to_ushort
        raw += (@us_max_context || 0).to_ushort
    end
    
end

end
end
end