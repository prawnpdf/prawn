# encoding: utf-8

# cells.rb: Methods for accessing rows, columns, and cells of a Prawn::Table.
#
# Copyright December 2009, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Table

    # Returns a Cells object that can be used to select and style cells. See
    # the Cells documentation for things you can do with cells.
    #
    def cells
      @cell_proxy ||= Cells.new(@cells)
    end

    # Selects the given rows (0-based) for styling. Returns a Cells object --
    # see the documentation on Cells for things you can do with cells.
    #
    def rows(row_spec)
      cells.rows(row_spec)
    end
    alias_method :row, :rows

    # Selects the given columns (0-based) for styling. Returns a Cells object
    # -- see the documentation on Cells for things you can do with cells.
    #
    def columns(col_spec)
      cells.columns(col_spec)
    end
    alias_method :column, :columns

    # Represents a selection of cells to be styled. Operations on a CellProxy
    # can be chained, and cell properties can be set one-for-all on the proxy.
    #
    # To set vertical borders only:
    #
    #   table.cells.borders = [:left, :right]
    #
    # To highlight a rectangular area of the table:
    #
    #   table.rows(1..3).columns(2..4).background_color = 'ff0000'
    #
    class Cells < Array

      # Limits selection to the given row or rows. +row_spec+ can be anything
      # that responds to the === operator selecting a set of 0-based row
      # numbers; most commonly a number or a range.
      #
      #   table.row(0)     # selects first row
      #   table.rows(3..4) # selects rows four and five
      #
      def rows(row_spec)
        index_cells unless @indexed
        row_spec = transform_spec(row_spec, @row_count)
        Cells.new(@rows[row_spec] ||= select { |c|
                    row_spec.respond_to?(:include?) ?
                      row_spec.include?(c.row) : row_spec === c.row })
      end
      alias_method :row, :rows
      
      # Limits selection to the given column or columns. +col_spec+ can be
      # anything that responds to the === operator selecting a set of 0-based
      # column numbers; most commonly a number or a range.
      #
      #   table.column(0)     # selects first column
      #   table.columns(3..4) # selects columns four and five
      #
      def columns(col_spec)
        index_cells unless @indexed
        col_spec = transform_spec(col_spec, @column_count)
        Cells.new(@columns[col_spec] ||= select { |c|
                    col_spec.respond_to?(:include?) ? 
                      col_spec.include?(c.column) : col_spec === c.column })
      end
      alias_method :column, :columns

      # Allows you to filter the given cells by arbitrary properties.
      #
      #   table.column(4).filter { |cell| cell.content =~ /Yes/ }.
      #     background_color = '00ff00'
      #
      def filter(&block)
        Cells.new(select(&block))
      end

      # Retrieves a cell based on its 0-based row and column. Returns an
      # individual Cell, not a Cells collection.
      # 
      #   table.cells[0, 0].content # => "First cell content"
      #
      def [](row, col)
        find { |c| c.row == row && c.column == col }
      end

      # Supports setting multiple properties at once.
      #
      #   table.cells.style(:padding => 0, :border_width => 2)
      #
      # is the same as:
      #
      #   table.cells.padding = 0
      #   table.cells.border_width = 2
      #
      # You can also pass a block, which will be called for each cell in turn.
      # This allows you to set more complicated properties:
      #
      #   table.cells.style { |cell| cell.border_width += 12 }
      #
      def style(options={}, &block)
        each { |cell| cell.style(options, &block) }
      end

      # Returns the total width of all columns in the selected set.
      #
      def width
        column_widths = {}
        each do |cell| 
          column_widths[cell.column] = 
            [column_widths[cell.column], cell.width].compact.max
        end
        column_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns minimum width required to contain cells in the set.
      #
      def min_width
        column_min_widths = {}
        each do |cell| 
          column_min_widths[cell.column] = 
            [column_min_widths[cell.column], cell.min_width].compact.max
        end
        column_min_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns maximum width that can contain cells in the set.
      #
      def max_width
        column_max_widths = {}
        each do |cell| 
          column_max_widths[cell.column] = 
            [column_max_widths[cell.column], cell.max_width].compact.min
        end
        column_max_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns the total height of all rows in the selected set.
      #
      def height
        row_heights = {}
        each do |cell| 
          row_heights[cell.row] = 
            [row_heights[cell.row], cell.height].compact.max
        end
        row_heights.values.inject(0) { |sum, width| sum + width }
      end

      # Supports setting arbitrary properties on a group of cells.
      #
      #   table.cells.row(3..6).background_color = 'cc0000'
      #
      def method_missing(id, *args, &block)
        each { |c| c.send(id, *args, &block) }
      end

      protected
      
      # Defers indexing until rows() or columns() is actually called on the
      # Cells object. Without this, we would needlessly index the leaf nodes of
      # the object graph, the ones that are only there to be iterated over.
      #
      # Make sure to call this before using @rows or @columns.
      # 
      def index_cells
        @rows = {}
        @columns = {}

        each do |cell|
          @rows[cell.row] ||= []
          @rows[cell.row] << cell

          @columns[cell.column] ||= []
          @columns[cell.column] << cell
        end

        @row_count    = @rows.size
        @column_count = @columns.size

        @indexed = true
      end

      # Transforms +spec+, a column / row specification, into an object that
      # can be compared against a row or column number using ===. Normalizes
      # negative indices to be positive, given a total size of +total+.
      #
      def transform_spec(spec, total)
        case spec
        when Range
          transform_spec(spec.begin, total)..transform_spec(spec.end, total)
        when Integer
          spec < 0 ? (total + spec) : spec
        else # pass through
          spec
        end
      end
    end
  end
end
