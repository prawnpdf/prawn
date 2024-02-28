# frozen_string_literal: true

module Prawn
  class Document # rubocop: disable Style/Documentation
    # @group Experimental API

    # Defines the grid system for a particular document. Takes the number of
    # rows and columns and the width to use for the gutter as the
    # keys :rows, :columns, :gutter, :row_gutter, :column_gutter
    #
    # @note A completely new grid object is built each time `define_grid`
    #   is called. This means that all subsequent calls to grid() will use
    #   the newly defined Grid object -- grids are not nestable like
    #   bounding boxes are.
    #
    # @param options [Hash{Symbol => any}]
    # @option options :columns [Integer] Number of columns in the grid.
    # @option options :rows [Integer] Number of rows in the grid.
    # @option options :gutter [Number] Gutter size. `:row_gutter` and
    #   `:column_gutter` are ignored if specified.
    # @option options :row_gutter [Number] Row gutter size.
    # @option options :column_gutter [Number] Column gutter size.
    # @return [Grid]
    def define_grid(options = {})
      @boxes = nil
      @grid = Grid.new(self, options)
    end

    # A method that can either be used to access a particular grid on the page
    # or work with the grid system directly.
    #
    # @overload grid
    #   Get current grid.
    #
    #   @return [Grid]
    #
    # @overload grid(row, column)
    #   Get a grid box.
    #
    #   @param row [Integer]
    #   @param column [Integer]
    #   @return [GridBox]
    #
    # @overload grid(box1, box2)
    #   Get a grid multi-box.
    #
    #   @param box1 [Array(Integer, Integer)] Start box coordinates.
    #   @param box2 [Array(Integer, Integer)] End box coordinates.
    #   @return [MultiBox]
    def grid(*args)
      @boxes ||= {}
      @boxes[args] ||=
        if args.empty?
          @grid
        else
          g1, g2 = args

          if g1.is_a?(Array) && g2.is_a?(Array) &&
              g1.length == 2 && g2.length == 2
            multi_box(single_box(*g1), single_box(*g2))
          else
            single_box(g1, g2)
          end
        end
    end

    # A Grid represents the entire grid system of a Page and calculates
    # the column width and row height of the base box.
    #
    # @group Experimental API
    class Grid
      # @private
      # @return [Prawn::Document]
      attr_reader :pdf

      # Number of columns in the grid.
      # @return [Integer]
      attr_reader :columns

      # Number of rows in the grid.
      # @return [Integer]
      attr_reader :rows

      # Gutter size.
      # @return [Number]
      attr_reader :gutter

      # Row gutter size.
      # @return [Number]
      attr_reader :row_gutter

      # Column gutter size.
      # @return [Number]
      attr_reader :column_gutter

      # @param pdf [Prawn::Document]
      # @param options [Hash{Symbol => any}]
      # @option options :columns [Integer] Number of columns in the grid.
      # @option options :rows [Integer] Number of rows in the grid.
      # @option options :gutter [Number] Gutter size. `:row_gutter` and
      #   `:column_gutter` are ignored if specified.
      # @option options :row_gutter [Number] Row gutter size.
      # @option options :column_gutter [Number] Column gutter size.
      def initialize(pdf, options = {})
        valid_options = %i[columns rows gutter row_gutter column_gutter]
        Prawn.verify_options(valid_options, options)

        @pdf = pdf
        @columns = options[:columns]
        @rows = options[:rows]
        apply_gutter(options)
      end

      # Calculates the base width of boxes.
      #
      # @return [Float]
      def column_width
        @column_width ||= subdivide(pdf.bounds.width, columns, column_gutter)
      end

      # Calculates the base height of boxes.
      #
      # @return [Float]
      def row_height
        @row_height ||= subdivide(pdf.bounds.height, rows, row_gutter)
      end

      # Diagnostic tool to show all of the grid boxes.
      #
      # @param color [Color]
      # @return [void]
      def show_all(color = 'CCCCCC')
        rows.times do |row|
          columns.times do |column|
            pdf.grid(row, column).show(color)
          end
        end
      end

      private

      def subdivide(total, num, gutter)
        (Float(total) - (gutter * Float((num - 1)))) / Float(num)
      end

      def apply_gutter(options)
        if options.key?(:gutter)
          @gutter = Float(options[:gutter])
          @row_gutter = @gutter
          @column_gutter = @gutter
        else
          @row_gutter = Float(options[:row_gutter])
          @column_gutter = Float(options[:column_gutter])
          @gutter = 0
        end
      end
    end

    # A Box is a class that represents a bounded area of a page.
    # A Grid object has methods that allow easy access to the coordinates of
    # its corners, which can be plugged into most existing Prawn methods.
    #
    # @group Experimental API
    class GridBox
      # @private
      attr_reader :pdf

      def initialize(pdf, rows, columns)
        @pdf = pdf
        @rows = rows
        @columns = columns
      end

      # Mostly diagnostic method that outputs the name of a box as
      # col_num, row_num
      #
      # @return [String]
      def name
        "#{@rows},#{@columns}"
      end

      # @private
      def total_height
        Float(pdf.bounds.height)
      end

      # Width of a box.
      #
      # @return [Float]
      def width
        Float(grid.column_width)
      end

      # Height of a box.
      #
      # @return [Float]
      def height
        Float(grid.row_height)
      end

      # Width of the gutter.
      #
      # @return [Float]
      def gutter
        Float(grid.gutter)
      end

      # x-coordinate of left side.
      #
      # @return [Float]
      def left
        @left ||= (width + grid.column_gutter) * Float(@columns)
      end

      # x-coordinate of right side.
      #
      # @return [Float]
      def right
        @right ||= left + width
      end

      # y-coordinate of the top.
      #
      # @return [Float]
      def top
        @top ||= total_height - ((height + grid.row_gutter) * Float(@rows))
      end

      # y-coordinate of the bottom.
      #
      # @return [Float]
      def bottom
        @bottom ||= top - height
      end

      # x,y coordinates of top left corner.
      #
      # @return [Array(Float, Float)]
      def top_left
        [left, top]
      end

      # x,y coordinates of top right corner.
      #
      # @return [Array(Float, Float)]
      def top_right
        [right, top]
      end

      # x,y coordinates of bottom left corner.
      #
      # @return [Array(Float, Float)]
      def bottom_left
        [left, bottom]
      end

      # x,y coordinates of bottom right corner.
      #
      # @return [Array(Float, Float)]
      def bottom_right
        [right, bottom]
      end

      # Creates a standard bounding box based on the grid box.
      #
      # @yield
      # @return [void]
      def bounding_box(&blk)
        pdf.bounding_box(top_left, width: width, height: height, &blk)
      end

      # Drawn the box. Diagnostic method.
      #
      # @param grid_color [Color]
      # @return [void]
      def show(grid_color = 'CCCCCC')
        bounding_box do
          original_stroke_color = pdf.stroke_color

          pdf.stroke_color = grid_color
          pdf.text(name)
          pdf.stroke_bounds

          pdf.stroke_color = original_stroke_color
        end
      end

      private

      def grid
        pdf.grid
      end
    end

    # A MultiBox is specified by 2 Boxes and spans the areas between.
    #
    # @group Experimental API
    class MultiBox
      def initialize(pdf, box1, box2)
        @pdf = pdf
        @boxes = [box1, box2]
      end

      # @private
      attr_reader :pdf

      # Mostly diagnostic method that outputs the name of a box.
      #
      # @return [String]
      def name
        @boxes.map(&:name).join(':')
      end

      # @private
      def total_height
        @boxes[0].total_height
      end

      # Width of a box.
      #
      # @return [Float]
      def width
        right_box.right - left_box.left
      end

      # Height of a box.
      #
      # @return [Float]
      def height
        top_box.top - bottom_box.bottom
      end

      # Width of the gutter.
      #
      # @return [Float]
      def gutter
        @boxes[0].gutter
      end

      # x-coordinate of left side.
      #
      # @return [Float]
      def left
        left_box.left
      end

      # x-coordinate of right side.
      #
      # @return [Float]
      def right
        right_box.right
      end

      # y-coordinate of the top.
      #
      # @return [Float]
      def top
        top_box.top
      end

      # y-coordinate of the bottom.
      #
      # @return [Float]
      def bottom
        bottom_box.bottom
      end

      # x,y coordinates of top left corner.
      #
      # @return [Array(Float, Float)]
      def top_left
        [left, top]
      end

      # x,y coordinates of top right corner.
      #
      # @return [Array(Float, Float)]
      def top_right
        [right, top]
      end

      # x,y coordinates of bottom left corner.
      #
      # @return [Array(Float, Float)]
      def bottom_left
        [left, bottom]
      end

      # x,y coordinates of bottom right corner.
      #
      # @return [Array(Float, Float)]
      def bottom_right
        [right, bottom]
      end

      # Creates a standard bounding box based on the grid box.
      #
      # @yield
      # @return [void]
      def bounding_box(&blk)
        pdf.bounding_box(top_left, width: width, height: height, &blk)
      end

      # Drawn the box. Diagnostic method.
      #
      # @param grid_color [Color]
      # @return [void]
      def show(grid_color = 'CCCCCC')
        bounding_box do
          original_stroke_color = pdf.stroke_color

          pdf.stroke_color = grid_color
          pdf.text(name)
          pdf.stroke_bounds

          pdf.stroke_color = original_stroke_color
        end
      end

      private

      def left_box
        @left_box ||= @boxes.min_by(&:left)
      end

      def right_box
        @right_box ||= @boxes.max_by(&:right)
      end

      def top_box
        @top_box ||= @boxes.max_by(&:top)
      end

      def bottom_box
        @bottom_box ||= @boxes.min_by(&:bottom)
      end
    end

    private

    def single_box(rows, columns)
      GridBox.new(self, rows, columns)
    end

    def multi_box(box1, box2)
      MultiBox.new(self, box1, box2)
    end
  end
end
