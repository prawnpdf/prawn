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

class IO
    SIZEOF_USHORT = 2
    SIZEOF_ULONG = 4
    SIZEOF_FIXED = 4
    SIZEOF_LONG_DATE_TIME = 8
    SIZEOF_SHORT = SIZEOF_FWORD = 2
    SHORT_BOUND = 2 ** (8 * SIZEOF_SHORT - 1)
    USHORT_BOUND = SHORT_BOUND * 2

    def at_offset(offset)
        prev_pos = self.pos
        self.pos = offset
        ret = yield
        self.pos = prev_pos
        ret
    end

    alias :old_read :read

    #ef read(n)
    #   ret = old_read(n)
    #   raise Font::TTF::MalformedFont if ret.nil?
    #    ret
    #end

    def read_ushort
        read(SIZEOF_USHORT).unpack("n")[0]
    end
    alias :read_ufword :read_ushort
    alias :read_f2dot14 :read_ushort

    def read_ushorts(n)
        read(SIZEOF_USHORT * n).unpack("n#{n.to_s}")
    end
    alias :read_ufwords :read_ushorts
    alias :read_f2dot14s :read_ushorts

    def read_ulong
        read(SIZEOF_ULONG).unpack("N")[0]
    end

    def read_ulongs(n)
        read(SIZEOF_ULONG * n).unpack("N#{n.to_s}")
    end

    def read_fixed
        f = read_ulong
        #"%d.%d" % [f >> 16, f & 0xff00]
    end

    def read_ulong_as_text
        read(SIZEOF_ULONG)
    end

    def read_byte
        read(1).unpack("C")[0]
    end

    def read_bytes(n)
        read(n).unpack("C" + n.to_s)
    end

    def read_long_date_time
        # Don't know how to compute dates
        read(SIZEOF_LONG_DATE_TIME)
        ""
    end

    def read_short
        # No unpack support for signed network short 
        n = read_ushort
        n = n - 2 * SHORT_BOUND if n >= SHORT_BOUND
        n
    end
    alias :read_fword :read_short

    def read_shorts(n)
        arr = []
        n.times { arr << read_short }
        arr
    end
    alias :read_fwords :read_shorts

    def read_char
        read(1)
    end

    def read_chars(n)
        read(n)
    end

end

class Integer

    def to_ushort
        [self].pack("n")
    end
    alias :to_ufword :to_ushort
    alias :to_f2dot14 :to_ushort

    def to_ulong
        [self].pack("N")
    end
    alias :to_fixed :to_ulong

    def to_short
        n = self
        n + 2 * IO::SHORT_BOUND if n < 0
        n.to_ushort
    end
    alias :to_fword :to_short

    def to_byte
        [self].pack("C")
    end

end

class String

    def to_long_date_time
        # Don't know how to compute dates
        # So just returns something at the good size
        " " * IO::SIZEOF_LONG_DATE_TIME
    end

    def four_chars!
        str = self
        while str.length < 4
            str += " "
        end
        self.replace(str.slice(0,4))
    end
end

class Array

    def to_bytes
        self.pack("C*")
    end

    def to_ushorts
        self.pack("n*")
    end
    alias :to_ufwords :to_ushorts
    alias :to_f2dot14s :to_ushorts

    def to_shorts
        str = ""
        self.each do |int|
            str += int.to_short
        end
        str
    end
    alias :to_fwords :to_shorts

    def to_ulongs
        self.pack("N*")
    end
    alias :to_fixeds :to_ulongs

end

# This allows to sort an array of symbols as if they were strings
class Symbol
    
    def <=>(symb)
        self.to_s <=> symb.to_s
    end

end