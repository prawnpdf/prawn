module Prawn
  class Document
    class Table

      attr_reader :col_widths

      def initialize(data, document,options={})
        @data               = data
        @document           = document
        @font_size          = options[:font_size] || 12
        @horizontal_padding = options[:horizontal_padding] || 5
        @vertical_padding   = options[:vertical_padding]   || 5
        @border             = options[:border]    || 1
        @position           = options[:position]  || :left
        @headers            = options[:headers]
        calculate_column_widths
        (options[:widths] || {}).each do |index,width| 
          @col_widths[index] = width
        end
      end
      
      def calculate_column_widths
        @col_widths = [0] * @data[0].length
        renderable_data.each do |row|
          row.each_with_index do |cell,i|
            length = cell.lines.map { |e| 
              @document.font_metrics.string_width(e,@font_size) }.max +
                2*@horizontal_padding
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

      def renderable_data
        if @headers
          [@headers] + @data
        else
          @data
        end
      end

      def generate_table
        page_contents = []
        y_pos = @document.y

        @document.font_size(@font_size) do
          renderable_data.each_with_index do |row,index|
            c = Prawn::Graphics::CellBlock.new(@document)
            row.each_with_index do |e,i|
              c << Prawn::Graphics::Cell.new(:document => @document, 
                                             :text     => e, 
                                             :width    => @col_widths[i],
                                             :horizontal_padding => @horizontal_padding,
                                             :vertical_padding => @vertical_padding,
                                             :border   => @border,
                                             :border_style    => :sides )
            end


            # TODO: Give better access to margin_box
            if c.height > (x=y_pos - @document.instance_eval { @margin_box }.
                          absolute_bottom)
              draw_page(page_contents)
              @document.start_new_page
              if @headers
                page_contents = [page_contents[0]]
                y_pos = @document.y - page_contents[0].height
              else
                page_contents = []
                y_pos = @document.y
              end

            end

            page_contents << c

            y_pos -= c.height

            if index == renderable_data.length - 1
              draw_page(page_contents)
            end


          end
          @document.y -= @vertical_padding
        end
      end

      def draw_page(contents)
        if contents.length == 1
          contents.first.border_style = :all
        else
          if @headers
            contents.first.border_style = :all
          else
            contents.first.border_style = :no_bottom 
          end
          contents.last.border_style  = :no_top
        end
        contents.each { |x| x.draw }
      end
    end
  end
end
