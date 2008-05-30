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

# Kern is the Kerning table, which contains values for intercharacter spacing.
class Kern < Font::TTF::FontChunk

    # KerningSubtable is a base class for KerningSubtable0 and KerningSubtable2.
    class KerningSubtable < Font::TTF::FontChunk

        HORIZONTAL = 0b1
        MINIMUM = 0b10
        CROSS_STREAM = 0b100
        OVERRIDE = 0b1000

        attr_accessor :version, :coverage

        def initialize(table, offs_from_table=nil, length=nil)

            if not offs_from_table.nil? and not length.nil?
                super(table.font, table.offset + offs_from_table, length)
                @font.at_offset(@offset) do
                    @version = @font.read_ushort
                    @length = @font.read_ushort
                    @coverage = @font.read_ushort
                end
            end
        end

        # Returns the format (Fixnum) of the KerningSubtable.
        def format
            @coverage >> 8
        end
    end

    # KerningTable in format 0.
    class KerningSubtable0 < KerningSubtable

        KerningPair = Struct.new(:left, :right, :value)
        KERNING_PAIR_SIZE = 2 * IO::SIZEOF_USHORT + IO::SIZEOF_FWORD

        # An Array of KerningPair structures.
        attr_accessor :kerning_pairs

        def initialize(*args)
            super(*args)

            @kerning_pairs = []

            if exists_in_file?
                @font.at_offset(@offset + 3 * IO::SIZEOF_USHORT) do
                    @num_pairs = @font.read_ushort
                    @search_range = @font.read_ushort
                    @entry_selector = @font.read_ushort
                    @range_shift = @font.read_ushort
      
                    @num_pairs.times do
                        kp = KerningPair.new
                        kp.left = @font.read_ushort
                        kp.right = @font.read_ushort
                        kp.value = @font.read_fword
                        @kerning_pairs << kp
                    end
                end
            end

        end

        def update_for_search!
            res = 1
            power = 0
            while res <= @kerning_pairs.length
                res *= 2
                power += 1
            end
            @search_range = res * KERNING_PAIR_SIZE
            @entry_selector = power - 1
            @range_shift = (@kerning_pairs.length - res) * KERNING_PAIR_SIZE
        end
        private :update_for_search!

        def dump
            update_for_search!
            raw = (@version || 0).to_ushort
            len = 7 * IO::SIZEOF_USHORT + \
                  @kerning_pairs.length * KERNING_PAIR_SIZE
            raw += len.to_ushort
            raw += (@coverage || 1).to_ushort
            raw += @kerning_pairs.length.to_ushort
            raw += @search_range.to_ushort
            raw += @entry_selector.to_ushort
            raw += @range_shift.to_ushort
            @kerning_pairs.each do |kp|
                raw += kp.left.to_ushort
                raw += kp.right.to_ushort
                raw += kp.value.to_fword
            end
            raw
        end

    end

    # KerningTable in format 2. Not implemented.
    class KerningSubtable2 < KerningSubtable

    end

    # An Array of KerningSubtable (KerningSubtable0 or KerningSubtable2)
    # objects.
    attr_accessor :subtables

    def initialize(*args)
        super(*args)

        @subtables = []

        if exists_in_file?
            @font.at_offset(@offset) do
                @version = @font.read_ushort
                @num_tables = @font.read_ushort
            end           

            offs = 2 * IO::SIZEOF_USHORT
            @num_tables.times do
                @font.at_offset(@offset + offs) do
                    version = @font.read_ushort
                    length = @font.read_ushort
                    coverage = @font.read_ushort

                    @subtables << case coverage >> 8
                        when 0
                            KerningSubtable0.new(self, offs, length)
                        when 2
                            KerningSubtable2.new(self, offs, length)
                    end
                    offs += length
                end
            end
        end
    end

    # Returns an empty kerning subtable in format 0 that then may be added to
    # the subtables array.
    def get_new_kerning_subtable0
        KerningSubtable0.new(self)
    end

    # Returns an empty kerning subtable in format 2 that then may be added to
    # the subtables array.
    def get_new_kerning_subtable2
        KerningSubtable2.new(self)
    end

    # Dumps the kern table in binary raw format as may be found in a font
    # file.
    def dump
        raw = (@version || 0).to_ushort
        raw += @subtables.length.to_ushort
        @subtables.each do |subtbl|
            raw += subtbl.dump
        end
        raw
    end
    
end

end
end
end