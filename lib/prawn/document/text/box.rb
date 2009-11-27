# encoding: utf-8

# text/rectangle.rb : Implements text rectangles
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    module Text
      # Draws the requested text into a rectangle. When the text overflows
      # the rectangle, you can display ellipses, shrink to fit, or
      # truncate the text
      #   acceptable options:
      #
      #     :at is a two element array denoting the upper left corner
      #       of the rectangle
      #
      #     :width and :height are the width and height of the
      #       rectangle, respectively. They default to the rectangle
      #       bounded by :at and the lower right corner of the
      #       document bounds
      #
      #     :overflow is :truncate, :shrink_to_fit, :expand, or :ellipses,
      #       denoting the behavior when the amount of text exceeds the
      #       available space. Defaults to :truncate.
      #
      #     :leading is the amount of space between lines. Defaults to 0
      #
      #     :kerning is a boolean. Defaults to true. Note that if
      #       kerning is on, it will result in slower width
      #       computations
      #   
      #     :align is :center, :left, or :right. Defaults to :left
      #
      #     :min_font_size is the minimum font-size to use when
      #       :overflow is set to :shrink_to_fit (ie: the font size
      #       will not be reduced to less than this value, even if it
      #       means that some text will be cut off). Defaults to 5

      # +text+ must be UTF8-encoded.
      #
      def text_box(text, options)
        Text::Box.new(text, options.merge(:for => self)).render
      end

      # Provides rectangle shaped text capacity
      #
      class Box #:nodoc:
        VERSION = '0.3.2'
        attr_reader :text
        attr_reader :at

        def initialize(text, options={})
          Prawn.verify_options([:for, :width, :height, :at, :size,
                                :overflow, :leading, :kerning,
                                :align, :min_font_size, :final_gap], options)
          options = options.clone
          @overflow      = options[:overflow] || :truncate
          # we'll be messing with the strings encoding, don't change the users
          # original string
          @text_to_print = text.dup.strip
          @text          = nil
          
          @document      = options[:for]
          @at            = options[:at] || [@document.bounds.left, @document.y]
          @width         = options[:width] || @document.bounds.right - @at[0]
          @height        = options[:height] || @at[1] - @document.bounds.bottom
          @center        = [@at[0] + @width * 0.5, @at[1] + @height * 0.5]
          @final_gap     = options[:final_gap].nil? ? true : options[:final_gap]
          if @overflow == :expand
            # if set to expand, then we simply set the bottom
            # as the bottom of the document bounds, since that
            # is the maximum we should expand to
            @height = @at[1] - @document.bounds.bottom
            @overflow = :truncate
          end
          @min_font_size = options[:min_font_size] || 5
          @options = @document.text_options.merge(:size    => options[:size],
                                                  :leading => options[:leading],
                                                  :kerning => options[:kerning],
                                                  :align   => options[:align])
        end
        
        def render
          unprinted_text = ''
          @document.save_font do
            process_options

            unless @document.skip_encoding
              @document.font.normalize_encoding!(@text_to_print)
            end
            
            unless @overflow == :shrink_to_fit
              @document.font_size(@font_size) do
                unprinted_text = _render(@text_to_print)
              end
              break
            end
            
            # Decrease the font size until the text fits or the min font
            # size is reached
            while (unprinted_text = _render(@text_to_print, false)).length > 0 &&
                @font_size > @min_font_size
              @font_size -= 0.5
            end
            
            @document.font_size(@font_size) do
              unprinted_text = _render(@text_to_print)
            end
          end
          unprinted_text
        end
        
        def height
          return 0 if @baseline_y.nil? || @descender.nil?
          # baseline is already pushed down one line below the current
          # line, so we need to subtract line line_height and leading,
          # but we need to add in the descender since baseline is
          # above the descender
          -@baseline_y + @descender - @line_height - @leading
        end

        private

        def process_options
          # must be performed within a save_font bock because
          # document.process_text_options sets the font
          @document.process_text_options(@options)
          @font_size = @options[:size]
          @leading   = @options[:leading] || 0
          @kerning   = @options[:kerning]
          @align     = @options[:align] || :left
        end

        def _render(text_to_print, do_the_print=true)
          @line_height = @document.font.height
          @ascender = @document.font.ascender
          # font.descender returns a negative value, which confuses
          # things later on, so get its absolute value
          @descender = @document.font.descender.abs
          
          # we store the text printed on each line in an array, then
          # join the array with newlines, thereby representing the
          # simulated effect of what was actually printed
          printed_text = []
          
          # baseline_y starts one line height below the top of the
          # rectangle
          @baseline_y = -@line_height + @descender

          # while there is text remaining to display, and the bottom
          # of the next line does not extend below the bottom of the rectangle
          while text_to_print && text_to_print.length > 0 && @baseline_y > -@height
            # print a single line
            line_to_print = text_that_will_fit_on_current_line(text_to_print)

            # update the remaining text to print to that which was not
            # yet printed.
            text_to_print = text_to_print.slice(line_to_print.length..text_to_print.length)

            # Print the line (strip first to avoid interfering with alignment)
            # Record the text that was actually printed
            printed_text << print_line(line_to_print.strip, do_the_print)

            # move to the next line
            @baseline_y -= (@line_height + @leading)
          end

          remaining_text = text_to_print
          if do_the_print
            @text = printed_text.join("\n")
            @document.y = @at[1] + @baseline_y + @line_height + @leading - @descender
            @document.y += @line_height - @ascender unless @final_gap
          end
          remaining_text
        end
          
        # When overflow is set to ellipses, we only want to print
        # ellipses at the end of the last line, so we need to know
        # whether this is the last line
        def last_line?
          @baseline_y < -@height + @line_height
        end

        def print_line(line_to_print, do_the_print)
          # strip so that trailing white space doesn't interfere with alignment
          line_to_print.rstrip!
          
          if last_line? && @overflow == :ellipses
            if @document.width_of(line_to_print + "...", :kerning => @kerning) < @width
              line_to_print.insert(-1, "...")
            else
              line_to_print[-3..-1] = "..." if line_to_print.length > 3
            end
          end

          case(@align)
          when :left
            x = @center[0] - @width * 0.5
          when :center
            line_width = @document.width_of(line_to_print, :kerning => @kerning)
            x = @center[0] - line_width * 0.5
          when :right
            line_width = @document.width_of(line_to_print, :kerning => @kerning)
            x = @center[0] + @width * 0.5 - line_width
          end
          
          y = @at[1] + @baseline_y

          @document.text_at(line_to_print, :at => [x, y], :size => @font_size, :kerning => @kerning) if do_the_print
          
          line_to_print
        end
        
        def text_that_will_fit_on_current_line(string)
          scan_pattern = /\S+|\s+/
          
          output = ""

          string.each_line do |line|
            accumulated_width = 0
            line.scan(scan_pattern).each do |segment|
              segment_width = @document.width_of(segment, :size => @font_size, :kerning => @kerning)
        
              if accumulated_width + segment_width <= @width
                accumulated_width += segment_width
                output << segment
              else
                # if the line contains white space, don't split the
                # final word that doesn't fit, just return what fits nicely
                return output if output =~ /\s/
                
                # if there is no white space, then just print
                # whatever part of the last segment that will fit on the line
                begin
                  segment.unpack("U*").each do |char_int|
                    char = [char_int].pack("U")
                    accumulated_width += @document.width_of(char, :size => @font_size, :kerning => @kerning)
                    return output if accumulated_width >= @width
                    output << char
                  end
                rescue
                  segment.each_char do |char|
                    accumulated_width += @document.width_of(char, :size => @font_size, :kerning => @kerning)
                    return output if accumulated_width >= @width
                    output << char
                  end
                end
              end
            end
            return output
          end

          output
        end
      end
    end
  end
end
