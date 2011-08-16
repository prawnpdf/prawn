# encoding: utf-8
#
# column_box.rb: Extends BoundingBox to allow for columns of text
#
# Author Paul Ostazeski.

require "prawn/document/bounding_box"
module Prawn
  class Document

    # A column box is a bounding box with the additional property that when
    # text flows past the bottom, it will wrap first to another column on the
    # same page, and only flow to the next page when all the columns are
    # filled.
    #
    # column_box accepts the same parameters as bounding_box, as well as the
    # number of :columns and a :spacer (in points) between columns.
    #
    # Defaults are :columns = 3 and :spacer = font_size
    # 
    # Under PDF::Writer, "spacer" was known as "gutter"
    # 
    def column_box(*args, &block)
      init_column_box(block) do |parent_box|
        map_to_absolute!(args[0])
        @bounding_box = ColumnBox.new(self, parent_box, *args)
      end
    end

    private

    def init_column_box(user_block, options={}, &init_block)
      parent_box = @bounding_box

      init_block.call(parent_box)

      self.y = @bounding_box.absolute_top
      user_block.call
      self.y = @bounding_box.absolute_bottom unless options[:hold_position]

      @bounding_box = parent_box
    end
    
    # Implements the necessary functionality to allow Document#column_box to
    # work.
    #
    class ColumnBox < BoundingBox

      attr_reader :columns, :current_column

      def initialize(document, parent, point, options={}) #:nodoc:
        super
        @columns = options[:columns] || 3
        @spacer  = options[:spacer]  || @document.font_size
        @current_column = 0
      end

      # The column width, not the width of the whole box.  Used to calculate
      # how long a line of text can be.
      #
      def width
        super / @columns - @spacer
      end

      # Column width including the spacer.
      #
      def width_of_column
        width + @spacer
      end

      # x coordinate of the left edge of the current column
      #
      def left_side
        absolute_left + (width_of_column * @current_column)
      end

      # x co-orordinate of the right edge of the current column
      #
      def right_side
        columns_from_right = @columns - (1 + @current_column)
        absolute_right - (width_of_column * columns_from_right)
      end

      # Moves to the next column or starts a new page if currently positioned at
      # the rightmost column.
      def move_past_bottom 
        @current_column = (@current_column + 1) % @columns
        @document.y = @y
        if 0 == @current_column
          @document.start_new_page
        end
      end

      # BoundingBox#indent modifies @width, which doesn't work past column one.
      # If we just modify the spacing, we get the same effect.
      def indent(left_padding, &block)
        @x += left_padding
        @spacer += left_padding
        yield
      ensure
        @x -= left_padding
        @spacer -= left_padding
      end

    end
  end
end
