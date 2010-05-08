require "prawn/core/text/formatted/line_wrap"
require "prawn/core/text/formatted/arranger"

module Prawn
  module Core
    module Text
      module Formatted #:nodoc:
        module Wrap

          def initialize(array, options)
            super(array, options)
            @line_wrap = Prawn::Core::Text::Formatted::LineWrap.new
            @arranger = Prawn::Core::Text::Formatted::Arranger.new(@document)
          end
          

          # See the developer documentation for Prawn::Core::Text#wrap
          #
          # Formatted#wrap should set some of the variables slightly differently
          # than Text#wrap;
          #   <tt>@line_height</tt>::
          #        the height of the tallest fragment in the last printed line
          #   <tt>@descender</tt>::
          #        the descender height of the tallest fragment in the last
          #        printed line
          #   <tt>@ascender</tt>::
          #        the ascender heigth of the tallest fragment in the last
          #        printed line
          #
          # Returns any formatted text that was not printed
          #
          def wrap(array) #:nodoc:
            initialize_wrap(array)

            move_baseline = true
            while @arranger.unfinished?
              printed_fragments = []

              line_to_print = @line_wrap.wrap_line(:document => @document,
                                                   :kerning => @kerning,
                                                   :width => available_width,
                                                   :arranger => @arranger)

              move_baseline = false
              break unless enough_height_for_this_line?
              move_baseline_down

              accumulated_width = 0
              word_spacing = word_spacing_for_this_line
              while fragment = @arranger.retrieve_fragment
                fragment.word_spacing = word_spacing
                if fragment.text == "\n"
                  printed_fragments << "\n" if @printed_lines.last == ""
                  break
                end
                printed_fragments << fragment.text
                format_and_draw_fragment(fragment, accumulated_width,
                                         @line_wrap.width, word_spacing)
                accumulated_width += fragment.width
                fragment.finished
              end
              @printed_lines << printed_fragments.join("")
              break if @single_line
              move_baseline = true unless @arranger.finished?
            end
            move_baseline_down if move_baseline
            @text = @printed_lines.join("\n")

            @arranger.unconsumed
          end

          private

          def enough_height_for_this_line?
            @line_height = @arranger.max_line_height
            @descender   = @arranger.max_descender
            @ascender    = @arranger.max_ascender
            required_height = @baseline_y == 0 ? @line_height : @line_height + @descender
            if @baseline_y.abs + required_height > @height
              # no room for the full height of this line
              @arranger.repack_unretrieved
              false
            else
              true
            end
          end

          def initialize_wrap(array)
            @text = nil
            @arranger.format_array = array

            # these values will depend on the maximum value within a given line
            @line_height = 0
            @descender   = 0
            @ascender    = 0
            @baseline_y  = 0

            @printed_lines = []
          end

          def format_and_draw_fragment(fragment, accumulated_width,
                                       line_width, word_spacing)
            @arranger.apply_color_and_font_settings(fragment) do
              draw_fragment(fragment, accumulated_width,
                            line_width, word_spacing)
            end
          end

        end
      end
    end
  end
end
