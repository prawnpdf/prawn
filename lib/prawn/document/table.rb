module Prawn
  class Document
    class Table

      attr_reader :col_widths

      def initialize(data, document,options={})
        @data               = data
        @document           = document
        @font_size          = options[:font_size] || 12
        @horizontal_spacing = options[:horizontal_spacing] || 5
        @vertical_spacing   = options[:vertical_spacing]  || 5
        calculate_column_widths
      end
      
      def calculate_column_widths
        @col_widths = Hash.new(0)
        @data.each do |row|
          row.each_with_index do |cell,i|
            length = cell.lines.map { |e| 
              @document.font_metrics.string_width(e,@font_size) }.max
            @col_widths[i] = length if length > @col_widths[i]
          end
        end
      end

      def draw
        @document.font_size(@font_size) do
          y = @document.y
          @data.each do |row|
            x = @document.bounds.absolute_left
            lines = 1
            row.each_with_index do |col,i|
              col_lines = col.lines.length
              lines = col_lines if col_lines > lines
              width = @col_widths[i]
              @document.bounding_box([x,y], :width => width) do
                @document.text(col)
              end
              x += width + @horizontal_spacing
            end
            y -= (@document.font_metrics.font_height(@font_size) * lines) + @vertical_spacing
          end
        end
      end

    end
  end
end
