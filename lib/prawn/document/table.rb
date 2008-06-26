module Prawn
  class Document

    # Builds and renders a Document::Table object from raw data.
    # For details on the options that can be passed, see
    # Document::Table.new
    #
    #   data = [["Gregory","Brown"],["James","Healy"],["Jia","Wu"]]
    #
    #   Prawn::Document.generate("table.pdf") do
    #     table data, :headers => ["First Name", "Last Name"]
    #   end
    #
    def table(data,options={})
      Prawn::Document::Table.new(data,self,options).draw
    end

    class Table

      attr_reader :col_widths # :nodoc:

      def initialize(data, document,options={})
        @data                = data
        @document            = document
        @font_size           = options[:font_size] || 12
        @horizontal_padding  = options[:horizontal_padding] || 5
        @vertical_padding    = options[:vertical_padding]   || 5
        @border              = options[:border]    || 1
        @border_style        = options[:border_style]
        @position            = options[:position]  || :left
        @headers             = options[:headers]
        @row_colors          = options[:row_colors]

        @row_colors = ["ffffff","cccccc"] if @row_colors == :pdf_writer

        @original_row_colors = @row_colors.dup if @row_colors
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
                                             :border_style => :sides )
            end


            if c.height > (x=y_pos - @document.margin_box.absolute_bottom)
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
        return if contents.empty?

        if @border_style == :grid || contents.length == 1
          contents.each { |e| e.border_style = :all }
        else
          contents.first.border_style = @headers ? :all : :no_bottom
          contents.last.border_style  = :no_top
        end

        contents.each do |x| 
          if @row_colors
            x.background_color = @row_colors.unshift(@row_colors.pop).last
          end
          x.draw 
        end

        @row_colors = @original_row_colors.dup if @row_colors
      end
    end
  end
end
