# encoding: utf-8

# text/formatted/rectangle.rb : Implements text boxes with formatted text
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  class Table
    class Cell
      module Formatted
        # Generally, one would use the Prawn::Text::Formatted#formatted_text_box
        # convenience method. However, using Table::Cell::Formatted::Box.new lets
        # you create a formatted box with the table cell rotation algorithm. In
        # conjunction with #render(:dry_run => true) you can do look-ahead
        # calculations prior to placing text on the page, or to determine how much
        # vertical space was consumed by the printed text
        #
        class Box < Prawn::Text::Formatted::Box
          include Prawn::Table::Cell::Formatted::Wrap

          # drop rotate_around, which is not relevant to a table cell
          def valid_options
            Prawn::Core::Text::VALID_OPTIONS + [:at, :height, :width,
                                                :align, :valign,
                                                :rotate, 
                                                :overflow, :min_font_size,
                                                :leading, :character_spacing,
                                                :mode, :single_line,
                                                :skip_encoding,
                                                :document,
                                                :direction,
                                                :fallback_fonts,
                                                :draw_text_callback]
          end

          # The width available at this point in the box
          #
          def available_width
            if @rotate != 0 && 
              ((@rotate > 45 && @rotate < 135) || (@rotate > 225 && @rotate < 315))
              @height
            else
              @width
            end
          end

          # The height available at this point in the box
          #
          def available_height
            if @rotate != 0 && 
              ((@rotate > 45 && @rotate < 135) || (@rotate > 225 && @rotate < 315))
              @width
            else
              @height
            end
          end

          private

          def render_rotated(text)
            unprinted_text = ''

            x = @at[0] + @height/2.0 - 1.0
            y = @at[1] - @height/2.0 + 4.0

            @document.rotate(@rotate, :origin => [x, y]) do
              unprinted_text = wrap(text)
            end
            unprinted_text
          end

        end

      end
    end
  end
end
