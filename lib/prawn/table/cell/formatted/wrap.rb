module Prawn
  class Table
    class Cell
      module Formatted #:nodoc:
        module Wrap #:nodoc:
          include Prawn::Core::Text::Formatted::Wrap

          private

          def enough_height_for_this_line?
            @line_height = @arranger.max_line_height
            @descender   = @arranger.max_descender
            @ascender    = @arranger.max_ascender
            if @baseline_y == 0
              diff = @ascender + @descender
            else
              diff = @descender + @line_height + @leading
            end
            required_total_height = @baseline_y.abs + diff
            if required_total_height > available_height + 0.0001
              # no room for the full height of this line
              @arranger.repack_unretrieved
              false
            else
              true
            end
          end

        end
      end
    end
  end
end
