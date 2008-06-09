module Prawn
  class Document
    class Table

      attr_reader :col_widths

      def initialize(data, document)
        @data = data
        @document = document
        calculate_column_widths
      end
      
      def calculate_column_widths
        @col_widths = Hash.new(0)
        @data.each do |row|
          row.each_with_index do |cell,i|
            length = @document.font_metrics.string_width(cell,12)
            @col_widths[i] = length if length > @col_widths[i]
          end
        end
      end

      def draw
        horizontal_spacing = 5
        vertical_spacing   = 5
        y = @document.y
        @data.each do |row|
          x = @document.bounds.absolute_left
          row.each_with_index do |col,i|
            width = @col_widths[i]
            @document.bounding_box([x,y], :width => width) do
              @document.text(col)
            end
            x += width + horizontal_spacing
          end
          y -= @document.font_metrics.font_height(12) + vertical_spacing
        end
      end

    end
  end
end
