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

# Fpgm is the Font Program table. It is similar to the Cvt table except
# it is only run once, when the font is first used.
class Fpgm < Font::TTF::FontChunk

    attr_accessor :instructions

    def initialize(*args)
        super(*args)

        if exists_in_file?
            @font.at_offset(@offset) do
                @instructions = @font.read_bytes(@len)
            end
        end
    end

    # Dumps the fpgm table in binary raw format as may be found in a font
    # file.
    def dump
        (@instructions || []).to_bytes
    end
    
end

end
end
end