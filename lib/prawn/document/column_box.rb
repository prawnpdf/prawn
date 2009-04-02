# encoding: utf-8
#
# column_box.rb: Extends BoundingBox to allow for columns of text
#
# Author Paul Ostazeski.

require "prawn/document/bounding_box"

module Prawn
  class Document

    def column_box(*args, &block)
      init_column_box(block) do |_|
        translate!(args[0])
        @bounding_box = ColumnBox.new(self, *args)
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

    class ColumnBox < BoundingBox

      def initialize(parent, point, options={})
        super
        @columns = options[:columns] || 3
        @current_column = 0
      end

      def width
        @width / @columns
      end

      def left_side
        absolute_left + (width * @current_column)
      end

      def right_side
        columns_from_right = @columns - (1 + @current_column)
        absolute_right - (width * columns_from_right)
      end

      def move_past_bottom
        @current_column = (@current_column + 1) % @columns
        @parent.y = @y
        if 0 == @current_column
          @parent.start_new_page
        end
      end

    end
  end
end
