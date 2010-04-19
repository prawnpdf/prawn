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
                                                 :width => @width)

            remaining_text = remaining_text.slice(@line_wrap.consumed_char_count..
                                                  remaining_text.length)
            include_ellipses = (@overflow == :ellipses && last_line? &&
                              remaining_text.length > 0)
            printed_lines << draw_line(line_to_print, include_ellipses)
            @baseline_y -= (@line_height + @leading)
            break if @single_line
          end

          @text = printed_lines.join("\n")

          remaining_text
        end

        private

        def compute_word_spacing_for_this_line
          if @align != :justify || @line_wrap.width.to_f / @width.to_f < 0.75
            @word_spacing = 0
          else
            @word_spacing = (@width - @line_wrap.width) / @line_wrap.space_count
          end
        end

        def draw_line(line_to_print, include_ellipses)
          insert_ellipses(line_to_print) if include_ellipses

          case(@align)
          when :left, :justify
            x = @at[0]
          when :center
            x = @at[0] + @width * 0.5 - @line_wrap.width * 0.5
          when :right
            x = @at[0] + @width - @line_wrap.width
          end
          
          y = @at[1] + @baseline_y
          
          if @inked && @align == :justify
            compute_word_spacing_for_this_line
            @document.word_spacing(@word_spacing) {
              @document.draw_text!(line_to_print, :at => [x, y],
                                   :kerning => @kerning)
            }
          elsif @inked
            @document.draw_text!(line_to_print, :at => [x, y],
                                 :kerning => @kerning)
          end
          
          line_to_print
        end

        def insert_ellipses(line_to_print)
          if @document.width_of(line_to_print + "...",
                                :kerning => @kerning) < @width
            line_to_print.insert(-1, "...")
          else
            line_to_print[-3..-1] = "..." if line_to_print.length > 3
          end
        end

      end
    end
  end
end
