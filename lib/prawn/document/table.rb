# encoding: utf-8
#
# table.rb : Simple table drawing functionality
#
# Copyright June 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document

    # Builds and renders a Document::Table object from raw data.
    # For details on the options that can be passed, see
    # Document::Table.new
    #
    #   data = [["Gregory","Brown"],["James","Healy"],["Jia","Wu"]]
    #
    #   Prawn::Document.generate("table.pdf") do
    #     
    #     # Default table, without headers
    #     table(data)
    #
    #     # Default table with headers
    #     table data, :headers => ["First Name", "Last Name"]
    #
    #     # Very close to PDF::Writer's default SimpleTable output
    #     table data, :headers            => ["First Name", "Last Name"],
    #                 :font_size          => 10,
    #                 :vertical_padding   => 2,
    #                 :horizontal_padding => 5,
    #                 :position           => :center,
    #                 :row_colors         => :pdf_writer,
    #
    #     # Grid border style with explicit column widths.
    #     table data, :border_style => :grid,
    #                 :widths       => { 0 => 100, 1 => 150 }
    #
    #   end
    #
    def table(data,options={})
      Prawn::Document::Table.new(data,self,options).draw
    end

    # This class implements simple PDF table generation.
    # 
    # Prawn tables have the following features:
    #
    #   * Can be generated with or without headers
    #   * Can tweak horizontal and vertical padding of text
    #   * Minimal styling support (borders / row background colors)
    #   * Can be positioned by bounding boxes (left/center aligned) or an
    #     absolute x position
    #   * Automated page-breaking as needed
    #   * Column widths can be calculated automatically or defined explictly on a 
    #     column by column basis
    #
    # The current implementation is a bit barebones, but covers most of the
    # basic needs for PDF table generation.  If you have feature requests,
    # please share them at: http://groups.google.com/group/prawn-ruby
    #
    # Tables will be revisited before the end of the Ruby Mendicant project and
    # the most commonly needed functionality will likely be added.
    # 
    class Table

      attr_reader :col_widths # :nodoc:

      # Creates a new Document::Table object. This is generally called 
      # indirectly through Document#table but can also be used explictly.
      #
      # The <tt>data</tt> argument is a two dimensional array of strings,
      # organized by row, e.g. [["r1-col1","r1-col2"],["r2-col2","r2-col2"]].
      # As with all Prawn text drawing operations, strings must be UTF-8 encoded.
      #
      # The following options are available for customizing your tables, with
      # defaults shown in [] at the end of each description.
      #
      # <tt>:font_size</tt>:: The font size for the text cells . [12]
      # <tt>:horizontal_padding</tt>:: The horizontal cell padding in PDF points [5]
      # <tt>:vertical_padding</tt>:: The vertical cell padding in PDF points [5]
      # <tt>:padding</tt>:: Horizontal and vertical cell padding (overrides both)
      # <tt>:border</tt>:: With of border lines in PDF points [1]
      # <tt>:border_style</tt>:: If set to :grid, fills in all borders.  Otherwise, borders are drawn on columns only, not rows
      # <tt>:position</tt>:: One of <tt>:left</tt>, <tt>:center</tt> or <tt>n</tt>, where <tt>n</tt> is an x-offset from the left edge of the current bounding box
      # <tt>:widths:</tt> A hash of indices and widths in PDF points.  E.g. <tt>{ 0 => 50, 1 => 100 }</tt>
      # <tt>:row_colors</tt>:: An array of row background colors which are used cyclicly.   
      # <tt>:align</tt>:: Alignment of text in columns [:left]
      #
      # Row colors are specified as html encoded values, e.g.
      # ["ffffff","aaaaaa","ccaaff"].  You can also specify 
      # <tt>:row_colors => :pdf_writer</tt> if you wish to use the default color
      # scheme from the PDF::Writer library.
      #
      # See Document#table for typical usage, as directly using this class is
      # not recommended unless you know why you want to do it.
      #
      def initialize(data, document,options={})
        @data                = data
        @document            = document
        @font_size           = options[:font_size] || 12
        @border_style        = options[:border_style]
        @border              = options[:border]    || 1
        @position            = options[:position]  || :left
        @headers             = options[:headers]
        @row_colors          = options[:row_colors]   
        @align               = options[:align]

        @horizontal_padding  = options[:horizontal_padding] || 5
        @vertical_padding    = options[:vertical_padding]   || 5

        if options[:padding]
          @horizontal_padding = @vertical_padding = options[:padding]
        end

        
        @row_colors = ["ffffff","cccccc"] if @row_colors == :pdf_writer

        @original_row_colors = @row_colors.dup if @row_colors  
        
        calculate_column_widths(options[:widths])
      end
      
      # Width of the table in PDF points
      #
      def width
         @col_widths.inject(0) { |s,r| s + r }
      end
      
      # Draws the table onto the PDF document
      #
      def draw
        case(@position) 
        when :center
          x = (@document.bounds.width - width) / 2.0
          y = @document.y - @document.bounds.absolute_bottom
          @document.bounding_box [x, y], :width => width do
            generate_table
          end
        when Numeric     
          x = @position
          y = @document.y - @document.bounds.absolute_bottom
          @document.bounding_box [x,y], :width => width do
            generate_table
          end
        else
          generate_table
        end
      end

      private

      def calculate_column_widths(manual_widths=nil)
        @col_widths = [0] * @data[0].length    
        renderable_data.each do |row|
          row.each_with_index do |cell,i|
            length = cell.to_s.lines.map { |e| 
              @document.font_metrics.string_width(e,@font_size) }.max.to_f +
                2*@horizontal_padding
            @col_widths[i] = length if length > @col_widths[i]
          end
        end  
        
        # TODO: Could optimize here
        manual_widths.each { |k,v| @col_widths[k] = v } if manual_widths           
      end

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
              case(e)
              when Prawn::Graphics::Cell
                e.document = @document
                e.width    = @col_widths[i]
                e.horizontal_padding = @horizontal_padding
                e.vertical_padding   = @vertical_padding    
                e.border             = @border
                e.border_style       = :sides
                e.align              = @align
                c << e
              else
                c << Prawn::Graphics::Cell.new(
                  :document => @document, 
                  :text     => e.to_s, 
                  :width    => @col_widths[i],
                  :horizontal_padding => @horizontal_padding,
                  :vertical_padding => @vertical_padding,
                  :border   => @border,
                  :border_style => :sides,
                  :align    => @align ) 
              end   
            end

            if c.height > y_pos - @document.margin_box.absolute_bottom
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
          x.background_color = next_row_color if @row_colors
          x.draw 
        end

        reset_row_colors
      end

      def next_row_color
        @row_colors.unshift(@row_colors.pop).last
      end

      def reset_row_colors
        @row_colors = @original_row_colors.dup if @row_colors
      end

    end
  end
end
