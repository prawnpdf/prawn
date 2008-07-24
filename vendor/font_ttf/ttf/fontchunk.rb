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

# A FontChunk is a portion of font. It starts at an offset and has a given
# length. It is useful to handle tables that have not been implemented
# or to quickly get a dump for a table that has not been modified.
class FontChunk 

    attr_reader :font
    attr_accessor :offset, :len

    def initialize(font, offset=nil, len=nil)
        @font = font
        # When a FontChunk is modified by user,
        # offset and len are not true anymore
        @offset = offset
        @len = len
    end

    # Returns the end of the class name as a Symbol.
    # Will be useful for tables, which are subclasses of FontChunk.
    # For example, calling tag on Font::TTF:Table::Loca object will return
    # :loca.
    def tag
        t = self.class.name.split("::").last.downcase.to_sym
        t = :"OS/2" if t == :os2
        t
    end

    # Basically each table is a FontChunk and tables may be created by hand
    # (i.e. not exist in file yet). This method returns whether the FontChunk
    # already exists in file or not.
    def exists_in_file?
        not @offset.nil?
    end

    # Returns raw binary data of the FontChunk.
    def dump
        @font.at_offset(@offset) do
            @font.read(@len)
        end
    end

    # Returns a checksum of dump.
    def self.checksum(dump)
        # FIXME: this methods seems to be buggy
        len = ((raw.length + 3) & ~3) / IO::SIZEOF_ULONG
        sum = 0
        (len - 1).times do |i|
            ulong_str = raw.slice(i * IO::SIZEOF_ULONG, IO::SIZEOF_ULONG)
            ulong = ulong_str.unpack("N")[0]
            sum += ulong
        end        
        sum
    end

end

end
end