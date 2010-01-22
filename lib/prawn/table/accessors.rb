# encoding: utf-8

# accessors.rb: Methods for accessing rows, columns, and cells of a
# Prawn::Table.
#
# Copyright December 2009, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  
  class Table

    # Returns a CellProxy that can be used to select and style cells. See the
    # CellProxy documentation for things you can do with cells.
    #
    def cells
      @cell_proxy ||= CellProxy.new(@cells)
    end

    # Selects the given rows (0-based) for styling. Returns a CellProxy -- see
    # the documentation on CellProxy for things you can do with cells.
    #
    def rows(row_spec)
      cells.rows(row_spec)
    end
    alias_method :row, :rows

    # Selects the given columns (0-based) for styling. Returns a CellProxy --
    # see the documentation on CellProxy for things you can do with cells.
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
    class CellProxy
      def initialize(cells) #:nodoc:
        @cells = cells
      end

      # Iterates over cells in turn.
      #
      def each(&b)
        @cells.each(&b)
      end

      include Enumerable

      # Limits selection to the given row or rows. +row_spec+ can be anything
      # that responds to the === operator selecting a set of 0-based row
      # numbers; most commonly a number or a range.
      #
      #   table.row(0)     # selects first row
      #   table.rows(3..4) # selects rows four and five
      #
      def rows(row_spec)
        CellProxy.new(@cells.select { |c| row_spec === c.row })
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
        CellProxy.new(@cells.select { |c| col_spec === c.column })
      end
      alias_method :column, :columns

      # Selects cells based on a block.
      #
      #   table.column(4).select { |cell| cell.content =~ /Yes/ }.
      #     background_color = 'ff0000'
      #
      def select(&b)
        CellProxy.new(@cells.select(&b))
      end

      # Retrieves a cell based on its 0-based row and column. Returns a Cell,
      # not a CellProxy.
      # 
      #   table.cells[0, 0].content # => "First cell content"
      #
      def [](row, col)
        @cells.find { |c| c.row == row && c.column == col }
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
        @cells.each do |cell| 
          options.each { |k, v| cell.send("#{k}=", v) }
          block.call(cell) if block
        end
      end

      # Returns the total width of all columns in the selected set.
      #
      def width
        column_widths = {}
        @cells.each do |cell| 
          column_widths[cell.column] = 
            [column_widths[cell.column], cell.width].compact.max
        end
        column_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns minimum width required to contain cells in the set.
      #
      def min_width
        column_min_widths = {}
        @cells.each do |cell| 
          column_min_widths[cell.column] = 
            [column_min_widths[cell.column], cell.min_width].compact.max
        end
        column_min_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns maximum width that can contain cells in the set.
      #
      def max_width
        column_max_widths = {}
        @cells.each do |cell| 
          column_max_widths[cell.column] = 
            [column_max_widths[cell.column], cell.max_width].compact.min
        end
        column_max_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns the total height of all rows in the selected set.
      #
      def height
        row_heights = {}
        @cells.each do |cell| 
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
        @cells.each { |c| c.send(id, *args, &block) }
      end
    end

  end

end


