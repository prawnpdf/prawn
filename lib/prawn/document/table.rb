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
        @col_widths = [0] * @data[0].length
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

            row_height = @document.font_metrics.font_height(@font_size) * lines

            y -= (row_height) + @vertical_spacing

            # TODO: Need a shortcut for an absolute bounding box.

            @document.stroke_line [0, y - @document.bounds.absolute_bottom], 
                                  [x - @document.bounds.absolute_left, y - @document.bounds.absolute_bottom]

            @document.stroke_line [0, y + row_height - @document.bounds.absolute_bottom],
                                  [x - @document.bounds.absolute_left, y + row_height - @document.bounds.absolute_bottom]

            x = @document.bounds.left

            @document.stroke_line [x, y + row_height - @document.bounds.absolute_bottom],
                                  [x, y - @document.bounds.absolute_bottom]

            @col_widths.each do |w|
              x += w + @horizontal_spacing / 2.0
             @document.stroke_line [x, y + row_height - @document.bounds.absolute_bottom],
                                   [x, y - @document.bounds.absolute_bottom]
              x += @horizontal_spacing / 2.0
            end

          end
        end
      end

    end
  end
end
