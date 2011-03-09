module Prawn
  class Table
    module CellFactory
      extend self

      def register(cell)
        raise ArgumentError, "#{cell.class} not a subclass of Prawn::Table::Cell" unless cell.ancestors.include? Prawn::Table::Cell

        cells << cell
      end

      def cells
        @cells ||= []
      end

      def clear
        cells.clear
      end

      def find_cell_for_content(content)
        @cells.detect {|cell| cell.can_render_with?(content) }
      end
    end
  end
end