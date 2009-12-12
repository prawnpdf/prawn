# encoding: utf-8   

module Prawn
  class Table
    class Cell
      # TODO: doc
      class Text < Cell
        
        def initialize(pdf, point, options={})
          super
          @font_size  = options[:font_size]
          @font_style = options[:font_style]
          @font       = load_font(options[:font])
        end

        def natural_content_width
          # We have to use the font's width here, not the document's, to account
          # for :font_style
          @font.compute_width_of(@content, :size => @font_size)
        end

        def natural_content_height
          @pdf.save_font do
            @pdf.set_font(@font, @font_size)
            @pdf.height_of(@content, :width => content_width)
          end
        end

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
