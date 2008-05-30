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

# Vhea is the Vertical Header table.
class Vhea < Hea

    alias :advance_height_max :advance_max
    alias :min_top_side_bearing :min_side_bearing_1
    alias :min_bottom_side_bearing :min_side_bearing_2
    alias :y_max_extent :max_extent
    alias :number_of_vmetrics :number_of_metrics

    alias :advance_height_max= :advance_max=
    alias :min_top_side_bearing= :min_side_bearing_1=
    alias :min_bottom_side_bearing= :min_side_bearing_2=
    alias :y_max_extent= :max_extent=
    alias :number_of_vmetrics= :number_of_metrics=

    def initialize(*args)
        super(*args)
    end
    
end

end
end
end