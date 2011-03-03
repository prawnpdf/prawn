require "prawn/core/text/formatted/line_wrap"
require "prawn/core/text/formatted/arranger"

module Prawn
  module Core
    module Text
      module Formatted #:nodoc:
        module Wrap #:nodoc:

          def initialize(array, options)
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

            stop = false
            while !stop
              @line_wrap.wrap_line(:document => @document,
                                   :kerning => @kerning,
                                   :width => available_width,
                                   :arranger => @arranger)

              if enough_height_for_this_line?
                move_baseline_down
                print_line
              else
                stop = true
              end

              stop ||= @single_line || @arranger.finished?
            end
            @text = @printed_lines.join("\n")
            @arranger.unconsumed
          end

          private

          def print_line
            printed_fragments = []
            fragments_this_line = []

            word_spacing = word_spacing_for_this_line
            while fragment = @arranger.retrieve_fragment
              fragment.word_spacing = word_spacing
              if fragment.text == "\n"
                printed_fragments << "\n" if @printed_lines.last == ""
                break
              end
              printed_fragments << fragment.text
              fragments_this_line << fragment
            end

            accumulated_width = 0
            fragments_this_line.reverse! if @direction == :rtl
            fragments_this_line.each do |fragment|
              fragment.default_direction = @direction
              format_and_draw_fragment(fragment, accumulated_width,
                                       @line_wrap.width, word_spacing)
              accumulated_width += fragment.width
            end

            if "".respond_to?(:force_encoding)
              printed_fragments.map! { |s| s.force_encoding("utf-8") }
            end
            @printed_lines << printed_fragments.join
          end

          def word_spacing_for_this_line
            if @align == :justify &&
                @line_wrap.space_count > 0 &&
                @line_wrap.width.to_f / available_width.to_f >= 0.75
              (available_width - @line_wrap.width) / @line_wrap.space_count
            else
              0
            end
          end

          def enough_height_for_this_line?
            @line_height = @arranger.max_line_height
            @descender   = @arranger.max_descender
            @ascender    = @arranger.max_ascender
            if @baseline_y == 0
              diff = @ascender + @descender
            else
              diff = @descender + @line_height
            end
            required_total_height = @baseline_y.abs + diff
            if required_total_height > @height
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
