# encoding: utf-8

# Methods for accessing rows, columns, and cells of a Prawn::Table.

module Prawn
  
  class Table

    def cells
      CellProxy.new(@cells)
    end

    def rows(row_spec)
      cells.rows(row_spec)
    end
    alias_method :row, :rows

    def columns(col_spec)
      cells.columns(col_spec)
    end
    alias_method :column, :columns

    class CellProxy
      def initialize(cells)
        @cells = cells
      end

      def each(&b)
        @cells.each(&b)
      end

      include Enumerable

      def rows(row_spec)
        CellProxy.new(@cells.select { |c| row_spec === c.row })
      end
      alias_method :row, :rows

      def columns(col_spec)
        CellProxy.new(@cells.select { |c| col_spec === c.column })
      end
      alias_method :column, :columns

      def [](row, col)
        @cells.find { |c| c.row == row && c.column == col }
      end

      def select(&b)
        CellProxy.new(@cells.select(&b))
      end

      def style(options)
        @cells.each { |c| options.each { |k, v| c.send("#{k}=", v) } }
      end

      def method_missing(id, *args, &block)
        @cells.each { |c| c.send(id, *args, &block) }
      end
    end

  end

end


