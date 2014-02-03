module Prawn
  class Table
    # @private
    class ColumnWidthCalculator 
      def initialize(cells)
        @cells = cells

        @widths_by_column        = Hash.new(0)
        @rows_with_a_span_dummy  = Hash.new(false)
      end

      def natural_widths
        @cells.each do |cell|
          @rows_with_a_span_dummy[cell.row] = true if cell.is_a?(Cell::SpanDummy)
        end

        #calculate natural column width for all rows that do not include a span dummy
        @cells.each do |cell|
          unless @rows_with_a_span_dummy[cell.row]
            @widths_by_column[cell.column] = 
              [@widths_by_column[cell.column], cell.width.to_f].max
          end
        end

        #integrate natural column widths for all rows that do include a span dummy
        @cells.each do |cell|
          next unless @rows_with_a_span_dummy[cell.row]
          #the width of a SpanDummy cell will be calculated by the "mother" cell
          next if cell.is_a?(Cell::SpanDummy)

          if cell.colspan == 1
            @widths_by_column[cell.column] = 
              [@widths_by_column[cell.column], cell.width.to_f].max
          else
            #calculate the current with of all cells that will be spanned by the current cell
            current_width_of_spanned_cells = 
              @widths_by_column.to_a[cell.column..(cell.column + cell.colspan - 1)]
                               .collect{|key, value| value}.inject(0, :+)

            #update the Hash only if the new with is at least equal to the old one
            #due to arithmetic errors we need to ignore a small difference in the new and the old sum
            #the same had to be done in the column_widht_calculator#natural_width
            update_hash = ((cell.width.to_f - current_width_of_spanned_cells) > 
                           Prawn::FLOAT_PRECISION)
            
            if update_hash
              # Split the width of colspanned cells evenly by columns
              width_per_column = cell.width.to_f / cell.colspan
              # Update the Hash
              cell.colspan.times do |i|
                @widths_by_column[cell.column + i] = width_per_column
              end
            end
          end
        end

        @widths_by_column.sort_by { |col, _| col }.map { |_, w| w }
      end
    end
  end
end
