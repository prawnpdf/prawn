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

# Post is the PostScript table, which contains additional informations needed
# to use TrueType fonts on PostScript printers
class Post < Font::TTF::FontChunk

    attr_accessor :format_type, :italic_angle, :underline_position, 
                  :underline_thickness, :is_fixed_pitch,  
                  :min_mem_type_42, :max_mem_type_42, 
                  :min_mem_type_1, :max_mem_type_1, 
                  :num_glyphs
    # An Array of PostscriptName
    attr_accessor :names

    PostScriptName = Struct.new(:id, :str)

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @format_type = @font.read_ulong
                @italic_angle = @font.read_ulong
                @underline_position = @font.read_fword
                @underline_thickness = @font.read_fword
                @is_fixed_pitch = @font.read_ulong
                @min_mem_type_42 = @font.read_ulong
                @max_mem_type_42 = @font.read_ulong
                @min_mem_type_1 = @font.read_ulong
                @max_mem_type_1 = @font.read_ulong

                if format == 2
                    @num_glyphs = @font.read_ushort
                    if @num_glyphs != @font.get_table(:maxp).num_glyphs
                        raise "Number of glyphs is post table and " + \
                              "maxp table should be the same"
                    end
                    name_indices = @font.read_ushorts(@num_glyphs)
                    @names = []
                    @num_glyphs.times do |i|
                        name_id = name_indices[i]
                        if name_id <= 257
                            # standard Macintosh name
                            pn = PostScriptName.new
                            pn.id = name_indices[i]
                            pn.str = nil
                            @names << pn
                        elsif name_id >= 258 and name_id <= 32767
                            len = @font.read_byte    
                            pn = PostScriptName.new
                            pn.id = name_indices[i]
                            pn.str = @font.read(len)
                            @names << pn
                        end
                    end
                else
                    @num_glyphs = 0
                    @names = []
                end
            end
        end
    end

    def format
        {0x00010000 => 1,
         0x00020000 => 2,
         0x00025000 => 2.5,
         0x00030000 => 3}[@format_type]
    end

    # Dumps the post table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@format_type || 0).to_ulong
        raw += (@italic_angle || 0).to_ulong
        raw += (@underline_position || 0).to_fword
        raw += (@underline_thickness || 0).to_fword
        raw += (@is_fixed_pitch || 0).to_ulong
        raw += (@min_mem_type_42 || 0).to_ulong
        raw += (@max_mem_type_42 || 0).to_ulong
        raw += (@min_mem_type_1 || 0).to_ulong
        raw += (@max_mem_type_1 || 0).to_ulong

        if format == 2
            raw += (@names.length || 0).to_ushort
            raw += @names.collect { |n| n.id }.to_ushorts
            @names.collect { |n| n.str }.find_all { |n| n != nil }.each do
                |name|
                raw += name.length.to_byte
                raw += name
            end
        end

        raw
    end
   
end

end
end
end