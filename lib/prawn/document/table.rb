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
        @position           = options[:position]  || :left
        @headers            = options[:headers]
        @style = :all if options[:style] == :grid
        calculate_column_widths
        (options[:widths] || {}).each do |index,width| 
          @col_widths[index] = width
        end
      end
      
      def calculate_column_widths
        @col_widths = [0] * @data[0].length
        data_with_headers.each do |row|
          row.each_with_index do |cell,i|
            length = cell.lines.map { |e| 
              @document.font_metrics.string_width(e,@font_size) }.max +
                2*@padding
            @col_widths[i] = length if length > @col_widths[i]
          end
        end
      end

      def width
         @col_widths.inject(0) { |s,r| s + r }
      end

      def draw
        case(@position) 
        when :center
          x = ((@document.bounds.absolute_right + 
                @document.bounds.absolute_left ) / 2.0 ) - (width / 2.0)

          @document.bounding_box [x,@document.y], :width => width do
            generate_table
          end
        when Numeric
          x = @position
          @document.bounding_box [x,@document.y], :width => width do
            generate_table
          end
        else
          generate_table
        end
      end

      private

      def generate_table
        needs_headers   = !!@headers
        last_cell_block = nil
        @document.font_size(@font_size) do
          data_with_headers.each_with_index do |row,i|
            c = Prawn::Graphics::CellBlock.new(@document)

            style    = :all if needs_headers
            style    = :no_top if i == data_with_headers.size - 1
            style     = :no_bottom if i == 0 && !@headers
            style  ||= :sides 

            row.each_with_index do |e,i|
              c << Prawn::Graphics::Cell.new(
                :document => @document, 
                :text     => e, 
                :width    => @col_widths[i],
                :padding  => @padding,
                :border   => @border,
                :style    => @style || style )
            end
            # TODO: Give better access to margin_box
            if c.height > @document.y - @document.instance_eval { @margin_box }.
                          absolute_bottom
              @document.y += last_cell_block.height
              last_cell_block.map { |e| e.style = @style || :no_top }
              last_cell_block.draw
              @document.start_new_page
              c.map { |e| e.style = @style || :no_bottom }
            end
            c.draw
            needs_headers = false
            last_cell_block = c 
          end
          @document.y -= @padding
        end
      end

      def data_with_headers
        if @headers
          [@headers] + @data
        else
          @data
        end
      end

    end
  end
end
