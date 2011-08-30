# encoding: utf-8   

# text.rb: Text table cells.
#
# Copyright December 2009, Gregory Brown and Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class Table
    class Cell

      # A Cell that contains text. Has some limited options to set font family,
      # size, and style.
      #
      class Text < Cell

        TextOptions = [:inline_format, :kerning, :size, :align, :valign,
          :rotate, :rotate_around, :leading, :single_line, :skip_encoding,
          :overflow, :min_font_size]

        TextOptions.each do |option|
          define_method("#{option}=") { |v| @text_options[option] = v }
          define_method(option) { @text_options[option] }
        end

        attr_writer :font, :text_color

        def initialize(pdf, point, options={})
          @text_options = {}
          super
        end

        # Returns the font that will be used to draw this cell.
        #
        def font
          with_font { @pdf.font }
        end

        # Sets the style of the font in use. Equivalent to the Text::Box
        # +style+ option, but we already have a style method.
        #
        def font_style=(style)
          @text_options[:style] = style
        end

        # Returns the width of this text with no wrapping. This will be far off
        # from the final width if the text is long.
        #
        def natural_content_width
          [styled_width_of(@content), @pdf.bounds.width].min
        end

        # Returns the natural height of this block of text, wrapped to the
        # preset width.
        #
        def natural_content_height
          with_font do
            b = text_box(:width => content_width + FPTolerance)
            b.render(:dry_run => true)
            b.height + b.line_gap
          end
        end

        # Draws the text content into its bounding box.
        #
        def draw_content
          with_font do 
            @pdf.move_down((@pdf.font.line_gap + @pdf.font.descender)/2)
            with_text_color do
              text_box(:width => content_width + FPTolerance, 
                       :height => content_height + FPTolerance,
                       :at => [0, @pdf.cursor]).render
            end
          end
        end

        def set_width_constraints
          # Sets a reasonable minimum width. If the cell has any content, make
          # sure we have enough width to be at least one character wide. This is
          # a bit of a hack, but it should work well enough.
          min_content_width = [natural_content_width, styled_width_of("M")].min
          @min_width ||= padding_left + padding_right + min_content_width
          super
        end

        protected

        def with_font
          @pdf.save_font do
            options = {}
            options[:style] = @text_options[:style] if @text_options[:style]

            @pdf.font(@font || @pdf.font.name, options)

            yield
          end
        end

        def with_text_color
          old_color = @pdf.fill_color || '000000'
          @pdf.fill_color(@text_color) if @text_color
          yield
        ensure
          @pdf.fill_color(old_color)
        end
        
        def text_box(extra_options={})
          if @text_options[:inline_format]
            options = @text_options.dup
            options.delete(:inline_format)

            array = ::Prawn::Text::Formatted::Parser.to_array(@content)
            ::Prawn::Text::Formatted::Box.new(array,
              options.merge(extra_options).merge(:document => @pdf))
          else
            ::Prawn::Text::Box.new(@content, @text_options.merge(extra_options).
               merge(:document => @pdf))
          end
        end

        # Returns the width of +text+ under the given text options.
        #
        def styled_width_of(text)
          @pdf.width_of(text, @text_options)
        end

      end
    end
  end
end
