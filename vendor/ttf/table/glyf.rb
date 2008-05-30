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

# Glyf is the Glyph data table.
class Glyf < Font::TTF::FontChunk

    # Base class for SimpleGlyph and CompositeGlyph.
    class Glyph < Font::TTF::FontChunk

        attr_accessor :num_contours, :x_min, :y_min, :x_max, :y_max

        def initialize(table, offset=nil)
            @table = table
            @offset_from_table = offset
            super(@table.font, @table.offset + @offset_from_table)

            if exists_in_file?
                @font.at_offset(@offset) do
                    @num_contours = @font.read_short
                    @x_min = @font.read_fword
                    @y_min = @font.read_fword
                    @x_max = @font.read_fword
                    @y_max = @font.read_fword
                end
            end
        end

        def dump
            raw = (@num_contours || 0).to_short
            raw += (@x_min || 0).to_fword
            raw += (@y_min || 0).to_fword
            raw += (@x_max || 0).to_fword
            raw += (@y_max || 0).to_fword 
        end

        # Returns whether the glyph is composite or not.
        def composite?
            self.class == CompositeGlyph
        end

        # Returns whether is simple (i.e. not composite) or not.
        def simple?
            self.class == SimpleGlyph
        end

    end

    # SimpleGlyph class.
    class SimpleGlyph < Glyph

        Point = Struct.new(:rel_x, :abs_x, :rel_y, :abs_y, 
                          :end_of_contour, :on_curve)

        # Point is helper class which gives information on a point
        # such as it absolute (abs_x, abs_y) and relative (rel_x, rel_y)
        # coordinates
        class Point
            # Whether the point is end of contour or not.
            alias :end_of_contour? :end_of_contour
            # Whether the point is on curve or not.
            alias :on_curve? :on_curve

            # Whether the point is off curve or not.
            def off_curve?
                not on_curve?
            end
        end

        FLAG_ON_CURVE = 0b1
        FLAG_X_SHORT_VECTOR = 0b10
        FLAG_Y_SHORT_VECTOR = 0b100
        FLAG_REPEAT = 0b1000
        FLAG_X_IS_SAME = 0b10000
        FLAG_Y_IS_SAME = 0b100000

        attr_accessor :end_pts_of_contours, :instructions, :flags,
                      :x_coordinates, :y_coordinates

        def initialize(*args)
            super(*args)
            
            if exists_in_file?
                offs = @offset + IO::SIZEOF_SHORT + 4 * IO::SIZEOF_FWORD
                @font.at_offset(offs) do
                    @end_pts_of_contours = @font.read_ushorts(@num_contours)
                    instruction_len = @font.read_ushort
                    @instructions = @font.read_bytes(instruction_len)
                    unless @end_pts_of_contours.empty?
                        num_points = @end_pts_of_contours.last + 1
                    else
                        num_points = 0
                    end
                    @flags = []
                    while @flags.length < num_points
                        flag = @font.read_byte
                        @flags << flag
                        if flag & FLAG_REPEAT != 0
                            @font.read_byte.times do
                                @flags << flag
                            end
                        end
                    end
                    @x_coordinates = []
                    @y_coordinates = []
                    [[@x_coordinates, FLAG_X_SHORT_VECTOR, FLAG_X_IS_SAME],
                     [@y_coordinates, FLAG_Y_SHORT_VECTOR, FLAG_Y_IS_SAME]
                    ].each do |coordinates, short, same|
                        num_points.times do |i|
                            flag = @flags[i]
                            if flag & short != 0
                                # if the coordinate is a BYTE
                                if flag & same != 0
                                    coordinates << @font.read_byte
                                else
                                    coordinates << -@font.read_byte
                                end
                            else
                                # the coordinate is a SHORT
                                if flag & same != 0
                                    # same so 0 (relative coordinates)
                                    coordinates << 0
                                else
                                    coordinates << @font.read_short
                                end
                            end
                        end
                    end
                    @len = @font.pos - @offset
                end
            end

        end
        
        # Returns an Array of [x,y] pairs of relative coordinates.
        def rel_coordinates
            coords = []
            @x_coordinates.length.times do |i|
                coords << [@x_coordinates[i], @y_coordinates[i]]
            end
            coords
        end

        # Returns an Array of [x,y] pairs of absolute coordinates.
        def abs_coordinates
            abs_x = 0
            abs_y = 0
            coords = []
            rel_coordinates.each do |rel_x, rel_y|
                abs_x += rel_x
                abs_y += rel_y
                coords << [abs_x, abs_y]
            end
            coords
        end

        # Returns an Array of Point objects.
        def points
            x_abs = 0
            y_abs = 0
            pnts = []
            @x_coordinates.length.times do |i|
                pnt = Point.new
                pnt.rel_x = @x_coordinates[i]
                pnt.rel_y = @y_coordinates[i]
                x_abs += pnt.rel_x
                y_abs += pnt.rel_y
                pnt.abs_x = x_abs
                pnt.abs_y = y_abs
                pnt.end_of_contour = @end_pts_of_contours.include? i
                pnt.on_curve = (@flags[i] & FLAG_ON_CURVE != 0)
                pnts << pnt
            end
            pnts
        end

        def dump
            raw = super
            raw += @end_pts_of_contours.to_ushorts
            raw += @instructions.length.to_ushort
            raw += @instructions.to_bytes

            tmp = ""
            [[@x_coordinates, FLAG_X_SHORT_VECTOR, FLAG_X_IS_SAME],
                [@y_coordinates, FLAG_Y_SHORT_VECTOR, FLAG_Y_IS_SAME]
            ].each do |coordinates, short, same|
                coordinates.each_with_index do |coord, i|
                    if 0 <= coord and coord <= 255
                        @flags[i] = (@flags[i] | short) | same
                        tmp += coord.to_byte
                    elsif -255 <= coord and coord < 0
                        @flags[i] = (@flags[i] | short) & ~same
                        tmp += (-coord).to_byte
                    elsif coord == 0
                        @flags[i] = (@flags[i] & ~short) | same
                    else
                        @flags[i] = (@flags[i] & ~short) & ~same
                        tmp += coord.to_short
                    end
                end
            end

            # We write all flags rather than using the flag_repeat trick
            # So we unset the "repeat" bit for all flags
            # TODO: implement the repeat feature (this saves space)
            raw += @flags.collect { |f| f & ~FLAG_REPEAT }.to_bytes

            raw += tmp
        end
    end

    # CompositeGlyph class.
    class CompositeGlyph < Glyph

        GlyphComponent = Struct.new(:flags, :index, :args, :scale,
                                    :xscale, :yscale, :scale01, :scale10)

        ARG_1_AND_2_ARE_WORDS = 0b1
        ARGS_ARE_XY_VALUES = 0b10
        ROUND_XY_TO_GRID = 0b100
        WE_HAVE_A_SCALE = 0b1000
        RESERVED = 0b10000
        MORE_COMPONENTS = 0b100000
        WE_HAVE_AN_X_AND_Y_SCALE = 0b1000000
        WE_HAVE_A_TWO_BY_TWO = 0b10000000
        WE_HAVE_INSTRUCTIONS = 0b100000000
        USE_MY_METRICS = 0b1000000000

        # An Array of GlyphComponent objects
        attr_accessor :components
        # An Array of instructions (Fixnums)
        attr_accessor :instructions

        def initialize(*args)
            super(*args)
            
            if exists_in_file?
                offs = @offset + IO::SIZEOF_SHORT + 4 * IO::SIZEOF_FWORD
                @font.at_offset(offs) do
                    @components = []
                    continue = true
                    while continue
                        gc = GlyphComponent.new
                        gc.flags = @font.read_ushort
                        gc.index = @font.read_ushort
    
                        gc.args = []
                        if gc.flags & ARG_1_AND_2_ARE_WORDS != 0
                            gc.args[0] = @font.read_short
                            gc.args[1] = @font.read_short
                        else
                            gc.args[0] = @font.read_ushort
                        end
    
                        if gc.flags & WE_HAVE_A_SCALE != 0
                            gc.scale = @font.read_f2dot14
                        elsif gc.flags & WE_HAVE_AN_X_AND_Y_SCALE != 0
                            gc.xscale = @font.read_f2dot14
                            gc.yscale = @font.read_f2dot14
                        elsif gc.flags & WE_HAVE_A_TWO_BY_TWO != 0
                            gc.xscale  = @font.read_f2dot14
                            gc.scale01 = @font.read_f2dot14
                            gc.scale10 = @font.read_f2dot14
                            gc.yscale = @font.read_f2dot14
                        end
                        @components << gc
                        continue = (gc.flags & MORE_COMPONENTS != 0)
                    end

                    if @components.last.flags & \
                       WE_HAVE_INSTRUCTIONS != 0
                        inst_len = @font.read_ushort
                        @instructions = @font.read_bytes(inst_len)
                    else
                        @instructions = []
                    end

                    @len = @font.pos - @offset
                end
            end
        end

        def dump
            raw = super
            components_len = @components.length
            @components.each_with_index do |gc, i|
                flags = gc.flags
                tmp = ""
                if not gc.args.nil? and gc.args.length == 2
                    flags |= ARG_1_AND_2_ARE_WORDS 
                    tmp += gc.args[0].to_short
                    tmp += gc.args[1].to_short
                else
                    flags &= ~ARG_1_AND_2_ARE_WORDS
                    tmp += gc.args[0].to_ushort
                end
                if not gc.scale.nil?
                    flags |= WE_HAVE_A_SCALE
                    tmp += gc.scale.to_f2dot14
                elsif not gc.scale01.nil?
                    flags |= WE_HAVE_A_TWO_BY_TWO
                    tmp += gc.xscale.to_f2dot14
                    tmp += gc.scale01.to_f2dot14
                    tmp += gc.scale10.to_f2dot14
                    tmp += gc.yscale.to_f2dot14
                elsif not gc.xscale.nil?
                    flags |= WE_HAVE_AN_X_AND_Y_SCALE
                    tmp += gc.xscale.to_f2dot14
                    tmp += gc.yscale.to_f2dot14
                end

                if i < components_len - 1
                    flags |= MORE_COMPONENTS
                else
                    flags &= ~MORE_COMPONENTS
                    if @instructions.length > 0
                        flags |= WE_HAVE_INSTRUCTIONS
                    else
                        flags &= ~WE_HAVE_INSTRUCTIONS
                    end
                end
                raw += flags.to_ushort
                raw += gc.index.to_ushort
                raw += tmp
            end
            unless @instructions.empty?
                raw += @instructions.length.to_ushort
                raw += @instructions.to_bytes
            end
            raw
        end
    end

    attr_accessor :glyphs

    def initialize(*args)
        super(*args)
    end

    # Returns the kind of glyph at offset, i.e. either SimpleGlyph
    # or CompositeGlyph.
    def kind_of_glyph_at_offset(offs_from_table)
        @font.at_offset(@offset + offs_from_table) do
            num_contours = @font.read_short
            if num_contours >= 0
                SimpleGlyph
            else
                CompositeGlyph
            end
        end
    end

    def get_glyph_at_offset(offs_from_table)
        klass = kind_of_glyph_at_offset(offs_from_table)
        klass.new(self, offs_from_table)
    end

    def get_glyphs
        loca = @font.get_table(:loca)
        glyphs = []
        loca.glyph_offsets[0...-1].each do |off|
            glyphs << get_glyph_at_offset(off)
        end
        glyphs
    end
    private :get_glyphs

    # Returns all Glyph (SimpleGlyph or CompositeGlyph) in an Array.
    # This method may be real overkill if you just need to access a few glyphs.
    # In this case, you should use the loca table (Font::TTF::Table::Loca)
    # to get offsets and get_glyph_at_offset to get glyph associated with them.
    def glyphs
        @glyphs ||= get_glyphs
    end

    # Sets glyphs. new_glyphs is an Array of Glyph objects.
    def glyphs=(new_glyphs)
        @glyphs = new_glyphs
        @font.get_table(:maxp).num_glyphs = @glyphs.length
        @font.get_table(:post).num_glyphs = @glyphs.length
    end

    # Iterates over each glyph.
    # It does not load all glyphs like glyphs.each would do.
    def each_glyph
        loca = @font.get_table(:loca)
        glyphs = []
        loca.glyph_offsets[0...-1].each do |off|
            glyph = get_glyph_at_offset(off)
            yield glyph
        end
    end

    # Dumps the glyf table in binary raw format as may be found in a font
    # file.
    def dump
        raw = ""
        offs = 0
        glyph_offsets = []
        glyphs.each do |glyph|            
            glyph_offsets << offs
            dump = glyph.dump
            len = dump.length
            raw += dump
            # offsets should be multiples of SIZEOF_ULONG
            diff = len % IO::SIZEOF_ULONG
            raw += " " * diff
            offs += len + diff
        end
        # An additional offset is added so that the length of the last
        # glyph can be calculated: 
        # len of last glyph = additional offs - last glyph offs
        glyph_offsets << offs        

        # 2 ** 16 * 2 = 131072 is the maximum size supported
        # if the short format is used in the loca table
        # Using shorts saves two bytes per glyph!
        if offs < 131072
            @font.get_table(:head).index_to_loc_format = \
                Font::TTF::Table::Head::SHORT_FORMAT
        else
            @font.get_table(:head).index_to_loc_format = \
                Font::TTF::Table::Head::LONG_FORMAT
        end

        @font.get_table(:loca).glyph_offsets = glyph_offsets

        raw
    end
   
end

end
end
end