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

# Mtx is a base class for Hmtx and Vmtx.
class Mtx < Font::TTF::FontChunk

    def initialize(*args)
        super(*args)

        if self.tag == :hmtx
            @hea = :hhea
        else
            @hea = :vhea
        end

        if exists_in_file?
            @font.at_offset(@offset) do
                @metrics = []
                
                num_metrics = @font.get_table(@hea).number_of_metrics
                num_metrics.times do
                    @metrics << [@font.read_ufword, @font.read_fword]
                end
               
                @side_bearings = []

                (@font.get_table(:maxp).num_glyphs - num_metrics).times do
                    @side_bearings << @font.read_fword
                end
            end
        end
    end

    # Returns an Array of [advance_width, left/top_side_bearing] pairs.
    def metrics
        last_aw = @metrics.last[0]
        @metrics + @side_bearings.collect { |sb| [last_aw, sb] }
    end

    # Sets metrics.
    def metrics=(mtrx)
        len = mtrx.length
        raise "Number of (h/v)metrics must be equal to number of glyphs" \
            if len != @font.get_table(:maxp).num_glyphs
        @font.get_table(@hea).number_of_metrics = len
        @side_bearings = []
        @metrics = mtrx
    end

    # Dumps the (h/v)mtx table in binary raw format as may be found in a font
    # file.
    def dump
        raw = ""
        (@metrics || []).each do |advanced_width, side_bearing|
            raw += advanced_width.to_ufword
            raw += side_bearing.to_fword
        end
        (@side_bearings || []).each do |side_bearing|
            raw += side_bearing.to_fword
        end
        raw
    end
    
end

# Hmtx is the horizontal metrics table.
class Hmtx < Mtx

    alias :hmetrics :metrics
    alias :hmetrics= :metrics=

    def initialize(*args)
        super(*args)
    end
    
end

end
end
end