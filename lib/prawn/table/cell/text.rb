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

        attr_writer :font_size
        
        def initialize(pdf, point, options={})
          super
          @font ||= load_font(nil)
        end

        # Use the given font (a Prawn::Font object or font name).
        #
        def font=(font)
          @font = load_font(font)
        end

        # Set the font style to the given variant (:normal, :bold, :italic,
        # :bold_italic, etc.)
        #
        def font_style=(style)
          @font ||= @pdf.font
          @font_style = style
          # Update Font object if variant is changed
          @font = @pdf.find_font(@font.family, :style => style)
        end

        # Returns the width of this text with no wrapping.
        #
        def natural_content_width
          # We have to use the font's width here, not the document's, to account
          # for :font_style
          @font.compute_width_of(@content, :size => @font_size)
        end

        # Returns a reasonable minimum width. If the cell has any content, make
        # sure we have enough width to be at least one character wide. This is
        # a bit of a hack, but it should work well enough.
        #
        def min_width
          min_content_width = [@pdf.width_of(@content), @pdf.width_of("W")].min
          left_padding + right_padding + min_content_width
        end

        # Returns the natural height of this block of text, wrapped to the
        # preset width.
        #
        def natural_content_height
          @pdf.save_font do
            @pdf.set_font(@font, @font_size)
            @pdf.height_of(@content, :width => content_width + FPTolerance)
          end
        end

        # Draws the text content into its bounding box.
        #
        def draw_content
          @pdf.save_font do
            @pdf.set_font(@font, @font_size)
            # NOTE: line_gap and descender depend on @pdf.font_size.
            # This could be cleaner pending prawn changes 
            # (bradediger/prawn@font_size) moving size onto Font.
            @pdf.move_down((@font.line_gap + @font.descender)/2)
            @pdf.text(@content)
          end
        end

        private

        # Returns a Font object given a Font, a font name, or, if +font+ is nil,
        # the variant of the current font identified by @font_style.
        #
        def load_font(font)
          case font
          when Prawn::Font then font
          when String then @pdf.find_font(font)
          when nil then @pdf.find_font(@pdf.font.family, :style => @font_style)
          else @pdf.font
          end
        end

      end
    end
  end
end
