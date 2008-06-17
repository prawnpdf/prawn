module Prawn
  class Document
    class Table

      attr_reader :col_widths

      def initialize(data, document,options={})
        @data               = data
        @document           = document
        @font_size          = options[:font_size] || 12
        @padding            = options[:padding]   || 5
        @border             = options[:border]    || 1
        calculate_column_widths
      end
      
      def calculate_column_widths
        @col_widths = [0] * @data[0].length
        @data.each do |row|
          row.each_with_index do |cell,i|
            length = cell.lines.map { |e| 
              @document.font_metrics.string_width(e,@font_size) }.max +
                2*@padding
            @col_widths[i] = length if length > @col_widths[i]
          end
        end
      end

      def draw
        @document.font_size(@font_size) do
          @data.each do |row|
            c = Prawn::Graphics::CellBlock.new(@document)
            row.each_with_index do |e,i|
              c << Prawn::Graphics::Cell.new(:document => @document, 
                                             :text     => e, 
                                             :width    => @col_widths[i],
                                             :padding  => @padding,
                                             :border   => @border )
            end
            @document.start_new_page if c.height > @document.y
            c.draw
          end
          @document.y -= @padding
        end
      end
    end
  end
end
