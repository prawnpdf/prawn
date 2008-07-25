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

# Maxp is the Maximum profile tables, which establishes memory requirements
# for the associated font.
class Maxp < Font::TTF::FontChunk

    attr_accessor :version, :num_glyphs, :max_points, :max_contours, 
                  :max_composite_points, :max_composite_contours, 
                  :max_zones, :max_twilight_points, :max_storage, 
                  :max_function_defs, :max_instruction_defs, 
                  :max_stack_elements, :max_sizeof_instructions, 
                  :max_component_elements, :max_component_depth

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @version = @font.read_fixed
                @num_glyphs = @font.read_ushort
                @max_points = @font.read_ushort
                @max_contours = @font.read_ushort
                @max_composite_points = @font.read_ushort
                @max_composite_contours = @font.read_ushort
                @max_zones = @font.read_ushort
                @max_twilight_points = @font.read_ushort
                @max_storage = @font.read_ushort
                @max_function_defs = @font.read_ushort
                @max_instruction_defs = @font.read_ushort
                @max_stack_elements = @font.read_ushort
                @max_sizeof_instructions = @font.read_ushort
                @max_component_elements = @font.read_ushort
                @max_component_depth = @font.read_ushort
            end
        end
    end

    # Dumps the maxp table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@version || 0).to_fixed
        raw += (@num_glyphs || 0).to_ushort
        raw += (@max_points || 0).to_ushort
        raw += (@max_contours || 0).to_ushort
        raw += (@max_composite_points || 0).to_ushort
        raw += (@max_composite_contours || 0).to_ushort
        raw += (@max_zones || 0).to_ushort
        raw += (@max_twilight_points || 0).to_ushort
        raw += (@max_storage || 0).to_ushort
        raw += (@max_function_defs || 0).to_ushort
        raw += (@max_instruction_defs || 0).to_ushort
        raw += (@max_stack_elements || 0).to_ushort
        raw += (@max_sizeof_instructions || 0).to_ushort
        raw += (@max_component_elements || 0).to_ushort
        raw += (@max_component_depth || 0).to_ushort
    end
    
end

end
end
end