# encoding: utf-8
#
# table.rb: Table drawing functionality.
#
# Copyright December 2009, Brad Ediger. All rights reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'prawn/table/accessors'
require 'prawn/table/cell'
require 'prawn/table/cell/in_table'
require 'prawn/table/cell/text'
require 'prawn/table/cell/subtable'

module Prawn

  class Document
    
    # Set up and draw a table on this document. A block can be given, which will
    # be run prior to layout and drawing.
    #
    # See Prawn::Table#initialize for details on options.
    #
    def table(data, options={}, &block)
      t = Table.new(data, self, options, &block)
      t.draw
      t
    end

    # Set up, but do not draw, a table. Useful for creating subtables to be
    # inserted into another Table. Call #draw on the resulting Table to ink it.
    #
    def make_table(data, options={}, &block)
      Table.new(data, self, options, &block)
    end

  end

  class Table  

    # Set up a table on the given document. Arguments:
    #
    # * data: A two-dimensional array of cell-like objects. See below for 
    # options for this argument.
    # * document: The Prawn::Document instance on which to draw the table.
    # * options: A hash of attributes and values for the table. 
    #
    # The data array can contain any combination of:
    #
    # * String: Produces a text cell.
    # TODO: more types
    #
    # Options can include:
    #
    # * cell_style: A hash of style options to style all cells. See the
    # documentation on Prawn::Table::Cell for all cell style options.
    #
    def initialize(data, document, options={}, &block)
      @pdf = document
      @cells = make_cells(data)
      @header = false
      options.each { |k, v| send("#{k}=", v) }

      # Evaluate the block before laying out the table, to support things like:
      #
      #   pdf.table(data) do |table|
      #     table.rows(1..3).width = 72
      #   end
      #
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end

      set_column_widths
      set_row_heights
      position_cells
    end                                        

    # Number of rows in the table.
    #
    attr_reader :row_length

    # Number of columns in the table.
    #
    attr_reader :column_length

    # Manually set the width of the table.
    #
    attr_writer :width

    # Returns the width of the table in PDF points.
    #
    def width
      @width ||= [natural_width, @pdf.bounds.width].min
    end

    # Sets column widths given:
    #
    # * Array: [w0, w1, w2, ...]
    # * Hash: {0 => w0, 1 => w1, ...]
    # * Numeric: 72
    #
    def column_widths=(widths)
      case widths
      when Array
        widths.each_with_index { |w, i| column(i).width = w }
      when Hash
        widths.each { |i, w| column(i).width = w }
      when Numeric
        columns.width = widths
      else
        raise ArgumentError, "cannot interpret column widths"
      end
    end

    # Returns the height of the table in PDF points.
    #
    def height
      cells.height
    end

    # If true, designates the first row as a header row to be repeated on every
    # page.
    #
    attr_writer :header

    # Sets styles for all cells.
    #
    #   pdf.table(data, :cell_style => { :borders => [:left, :right] })
    #
    def cell_style=(style_hash)
      cells.style(style_hash)
    end

    # Allows generic stylable content.
    #
    #   pdf.table(data) do
    #     style(row(0), :background_color => 'ff00ff')
    #     style(column(0)) { |c| c.border_width += 1 }
    #   end
    #
    def style(stylable, style_hash={}, &block)
      stylable.style(style_hash, &block)
    end

    # Draws the table onto the document.
    #
    def draw
      # The cell y-positions are based on an infinitely long canvas. The offset
      # keeps track of how much we have to add to the original, theoretical
      # y-position to get to the actual position on the current page.
      offset = @pdf.y

      # Reference bounds are the non-stretchy bounds used to decide when to
      # flow to a new column / page.
      ref_bounds = @pdf.bounds.stretchy? ? @pdf.margin_box : @pdf.bounds

      last_y = @pdf.y
      @cells.each do |cell|
        if cell.height > (cell.y + offset) - ref_bounds.absolute_bottom
          # start a new page or column
          @pdf.bounds.move_past_bottom
          draw_header
          offset = @pdf.y - cell.y
        end
 
        # Don't modify cell.x / cell.y here, as we want to reuse the original
        # values when re-inking the table. #draw should be able to be called
        # multiple times.
        x, y = cell.x, cell.y
        y += offset 

        # Translate coordinates to the bounds we are in, since drawing is 
        # relative to the cursor, not ref_bounds.
        x += @pdf.bounds.left_side - @pdf.bounds.absolute_left
        y -= @pdf.bounds.absolute_bottom

        cell.draw([x, y])
        last_y = y
      end

      @pdf.move_cursor_to(last_y - @cells.last.height)
    end

    protected

    
    def make_cells(data)
      assert_proper_table_data(data)

      cells = []
      
      @row_length = data.length
      @column_length = data.map{ |r| r.length }.max

      data.each_with_index do |row_cells, row_number|
        row_cells.each_with_index do |cell_data, column_number|
          cell = Cell.make(@pdf, cell_data)
          cell.extend(Cell::InTable)
          cell.row = row_number
          cell.column = column_number
          cells << cell
        end
      end
      cells
    end

    def assert_proper_table_data(data)
      if data.nil? || data.empty?
        raise Prawn::Errors::EmptyTable,
          "data must be a non-empty, non-nil, two dimensional array " +
          "of cell-convertible objects"
      end

      unless data.all? { |e| Array === e }
        raise Prawn::Errors::InvalidTableData,
          "data must be a two dimensional array of Prawn::Cells or strings"
      end
    end

    def draw_header
      if @header
        y = @pdf.cursor
        row(0).each do |cell|
          cell.y = y
          cell.draw
        end
        @pdf.move_cursor_to(y - row(0).height)
      end
    end

    def natural_column_widths
      @natural_column_widths ||= (0...column_length).map { |c| column(c).width }
    end

    def natural_width
      @natural_width ||= natural_column_widths.inject(0) { |sum, w| sum + w }
    end

    def column_widths
      @column_widths ||= begin
        if width < cells.min_width
          raise Errors::CannotFit,
            "Table's width was set too small to contain its contents"
        end

        if width > cells.max_width
          raise Errors::CannotFit,
            "Table's width was set larger than its contents' maximum width"
        end

        if width < natural_width
          # Shrink the table to fit the requested width.
          f = (width - cells.min_width).to_f / (natural_width - cells.min_width)

          (0...column_length).map do |c|
            min, nat = column(c).min_width, column(c).width
            (f * (nat - min)) + min
          end
        elsif width > natural_width
          # Expand the table to fit the requested width.
          f = (width - cells.width).to_f / (cells.max_width - cells.width)

          (0...column_length).map do |c|
            nat, max = column(c).width, column(c).max_width
            (f * (max - nat)) + nat
          end
        else
          natural_column_widths
        end
      end
    end

    def row_heights
      @natural_row_heights ||= (0...row_length).map{ |r| row(r).height }
    end

    def set_column_widths
      column_widths.each_with_index do |w, col_num| 
        column(col_num).width = w
      end
    end

    def set_row_heights
      row_heights.each_with_index { |h, row_num| row(row_num).height = h }
    end

    # Set each cell's position based on the widths and heights of cells
    # preceding it.
    #
    def position_cells
      # Calculate x- and y-positions as running sums of widths / heights.
      x_positions = column_widths.inject([0]) { |ary, x| 
        ary << (ary.last + x); ary }[0..-2]
      x_positions.each_with_index { |x, i| column(i).x = x }

      # y-positions assume an infinitely long canvas starting at zero -- this
      # is corrected for in Table#draw, and page breaks are properly inserted.
      y_positions = row_heights.inject([0]) { |ary, y|
        ary << (ary.last - y); ary}[0..-2]
      y_positions.each_with_index { |y, i| row(i).y = y }
    end

  end


end
