require "prawn/core/text/line_wrap"

module Prawn
  module Core
    module Text
      module Wrap #:nodoc:

        def initialize(text, options)
          @line_wrap = Prawn::Core::Text::LineWrap.new
        end

        # #wrap is part of the developer API. Override it in extensions to Prawn
        # that inherit Text::Box but need a different placement algorithm.
        # #wrap is where the actual placement of text happens. If @inked is
        # false, then all the placement computations should be performed, and
        # unprinted text returned, but no text should actually be drawn to the
        # PDF. This enables look-ahead computations that need to know whether all
        # the text was printed under a set of conditions or how tall the text was
        # under certain conditions.
        #
        # #wrap is called from several places within box.rb and relies on
        # certain conditions established by render. Do not call #wrap from
        # outside of Text::Box or its descendants.
        #
        # #wrap should set the following instance variables:
        #   <tt>@text</tt>:: the text that was printed
        #   <tt>@line_height</tt>:: the height of the last printed line
        #   <tt>@descender</tt>:: the descender height of the last printed line
        #   <tt>@ascender</tt>:: the ascender heigth of the last printed line
        #   <tt>@baseline_y</tt>:: the base line of the last printed line
        #
        # Returns any unprinted text
        #
        def wrap(text) #:nodoc:
          @text = nil
          remaining_text = text
          @line_height = @document.font.height
          @descender   = @document.font.descender
          @ascender    = @document.font.ascender
          @baseline_y  = -@ascender

          printed_lines = []

          while remaining_text &&
              remaining_text.length > 0 &&
              @baseline_y.abs + @descender <= @height
            line_to_print = @line_wrap.wrap_line(remaining_text.first_line,
                                                 :document => @document,
                                                 :kerning => @kerning,
                                                 :width => available_width)

            remaining_text = remaining_text.slice(@line_wrap.consumed_char_count..
                                                  remaining_text.length)
            include_ellipses = (@overflow == :ellipses && last_line? &&
                                remaining_text.length > 0)
            printed_lines << draw_line(line_to_print, @line_wrap.width,
                                       word_spacing_for_this_line, include_ellipses)
            @baseline_y -= (@line_height + @leading)
            break if @single_line
          end

          @text = printed_lines.join("\n")

          remaining_text
        end

        private

        def word_spacing_for_this_line
          if @align != :justify || @line_wrap.width.to_f / available_width.to_f < 0.75
            0
          else
            (available_width - @line_wrap.width) / @line_wrap.space_count
          end
        end

      end
    end
  end
end
