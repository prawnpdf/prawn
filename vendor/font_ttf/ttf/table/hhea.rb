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

# Hea is a base class for Hhea and Vhea.
class Hea < Font::TTF::FontChunk

    attr_accessor :version, :ascender, :descender, :line_gap, 
                  :advance_max, :min_side_bearing_1, 
                  :min_side_bearing_2, :max_extent, 
                  :caret_slope_rise, :caret_slope_run, 
                  :metric_data_format, :number_of_metrics

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @version = @font.read_fixed
                @ascender = @font.read_fword
                @descender = @font.read_fword
                @line_gap = @font.read_fword
                @advance_max = @font.read_ufword
                @min_side_bearing_1 = @font.read_fword
                @min_side_bearing_2 = @font.read_fword
                @max_extent = @font.read_fword
                @caret_slope_rise = @font.read_short
                @caret_slope_run = @font.read_short
                5.times { @font.read_fword } # reserved, unused fields
                @metric_data_format = @font.read_short
                @number_of_metrics = @font.read_ushort
            end
        end
    end

    # Dumps the hhea table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@version || 0).to_fixed
        raw += (@ascender || 0).to_fword
        raw += (@descender || 0).to_fword
        raw += (@line_grap || 0).to_fword
        raw += (@advance_max || 0).to_ufword
        raw += (@min_side_bearing_1 || 0).to_fword
        raw += (@min_side_bearing_2 || 0).to_fword
        raw += (@max_extent || 0).to_fword
        raw += (@caret_slope_rise || 0).to_short
        raw += (@caret_slope_run || 0).to_short
        5.times { raw += 0.to_fword } # reserved, unused fields
        raw += (@metric_data_format || 0).to_short
        raw += (@number_of_metrics || 0).to_ushort
    end
    
end

# Hhea is the Horizontal header table.
class Hhea < Hea

    alias :advance_width_max :advance_max
    alias :min_left_side_bearing :min_side_bearing_1
    alias :min_right_side_bearing :min_side_bearing_2
    alias :x_max_extent :max_extent
    alias :number_of_hmetrics :number_of_metrics

    alias :advance_width_max= :advance_max=
    alias :min_left_side_bearing= :min_side_bearing_1=
    alias :min_right_side_bearing= :min_side_bearing_2=
    alias :x_max_extent= :max_extent=
    alias :number_of_hmetrics= :number_of_metrics=

    def initialize(*args)
        super(*args)
    end
    
end

end
end
end