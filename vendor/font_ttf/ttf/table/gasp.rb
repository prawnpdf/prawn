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

# Gasp is the Grid-fitting and scan conversion procedure table.
class Gasp < Font::TTF::FontChunk

    class GaspRange < Font::TTF::FontChunk

        SIZEOF_GASP_RANGE = 2 * IO::SIZEOF_USHORT

        attr_accessor :range_max_ppem, :range_gasp_behavior

        def initialize(table, n=nil)
            if n.nil?
                # when object is created by hand
                super(table.font)
            else
                offs = table.offset + 2 * IO::SIZEOF_USHORT + \
                       n * SIZEOF_GASP_RANGE
                super(table.font, offs, SIZEOF_GASP_RANGE)

                table.font.at_offset(@offset) do
                    @range_max_ppem = table.font.read_ushort
                    @range_gasp_behavior = table.font.read_ushort
                end
            end
        end

        def dump
            raw = (@range_max_ppem || 0).to_ushort
            raw += (@range_gasp_behavior || 0).to_ushort
        end

    end

    attr_accessor :version
    # An Array of GaspRange objects.
    attr_accessor :gasp_ranges

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @version = @font.read_ushort
                @num_ranges = @font.read_ushort
                @gasp_ranges = []
                @num_ranges.times do |i|
                    @gasp_ranges << GaspRange.new(self, i)
                end
            end
        end
    end

    # Dumps the gasp table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@version || 0).to_ushort
        raw += (@gasp_ranges || []).length.to_ushort
        @gasp_ranges.each do |gr|
            raw += gr.dump
        end
        raw
    end
    
end

end
end
end