# encoding: utf-8

# text/rectangle.rb : Implements text boxes
#
# Copyright November 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    module Text
      # Draws the requested text into a box. When the text overflows
      # the rectangle, you can display ellipses, shrink to fit, or
      # truncate the text
      #   acceptable options:
      #
      #     :at is a two element array denoting the upper left corner
      #       of the rectangle. It defaults to the current document.y
      #       and document.bounds.left
      #
      #     :width and :height are the width and height of the
      #       rectangle, respectively. They default to the rectangle
      #       bounded by :at and the lower right corner of the
      #       document bounds
      #
      #     :leading is the amount of space between lines. Defaults to 0
      #
      #     :kerning is a boolean. Defaults to true. Note that if
      #       kerning is on, it will result in slower width
      #       computations
      #   
      #     :align is :center, :left, or :right. Defaults to :left
      #
      #     :overflow is :truncate, :shrink_to_fit, :expand, or :ellipses,
      #       denoting the behavior when the amount of text exceeds the
      #       available space. Defaults to :truncate.
      #
      #     :min_font_size is the minimum font-size to use when
      #       :overflow is set to :shrink_to_fit (ie: the font size
      #       will not be reduced to less than this value, even if it
      #       means that some text will be cut off). Defaults to 5
      #
      #     :wrap_block is a block that is passed a single line and
      #       options consisting of :document (the pdf object),
      #       :kerning, :size (the font size), and :width (the width
      #       available for the current line of text)

      def text_box(text, options)
        Text::Box.new(text, options.merge(:for => self)).render
      end

      class Box #:nodoc:
        VERSION = '0.3.2'
        attr_reader :text
        attr_reader :at

        def valid_options
          Text::VALID_TEXT_OPTIONS.dup.concat([:align, :final_gap, :for,
                                               :height, :min_font_size,
                                               :overflow, :width, :wrap_block])
        end

        def initialize(text, options={})
          Prawn.verify_options(valid_options, options)
          options        = options.dup
          @overflow      = options[:overflow] || :truncate
          # we'll be messing with the strings encoding, don't change the user's
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
          @wrap_block    = options [:wrap_block] || default_wrap_block
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

            @document.font_size(@font_size) do
              shrink_to_fit if @overflow == :shrink_to_fit
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

        # Decrease the font size until the text fits or the min font
        # size is reached
        def shrink_to_fit
          while (unprinted_text = _render(@text_to_print, false)).length > 0 &&
              @font_size > @min_font_size
            @font_size -= 0.5
          end
        end

        def process_options
          # must be performed within a save_font bock because
          # document.process_text_options sets the font
          @document.process_text_options(@options)
          @font_size = @options[:size]
          @leading   = @options[:leading] || 0
          @kerning   = @options[:kerning]
          @align     = @options[:align] || :left
        end

        def _render(remaining_text, do_the_print=true)
          @line_height = @document.font.height
          @ascender = @document.font.ascender
          @descender = @document.font.descender.abs
          @baseline_y = -@line_height + @descender
          
          printed_text = []
          
          while remaining_text && remaining_text.length > 0 && @baseline_y > -@height
            line_to_print = @wrap_block.call(remaining_text.first_line,
                                             :document => @document,
                                             :kerning => @kerning,
                                             :size => @font_size,
                                             :width => @width)
            remaining_text = remaining_text.slice(line_to_print.length..remaining_text.length)
            printed_text << print_line(line_to_print, do_the_print)
            @baseline_y -= (@line_height + @leading)
          end

          if do_the_print
            @text = printed_text.join("\n")
            @document.y = @at[1] + @baseline_y + @line_height + @leading - @descender
            @document.y += @line_height - @ascender unless @final_gap
          end
          remaining_text
        end

        def print_line(line_to_print, do_the_print)
          # strip so that trailing and preceding white space don't interfere with alignment
          line_to_print.strip!
          
          insert_elipses(line_to_print) if @overflow == :ellipses && last_line?

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
          
        def last_line?
          @baseline_y < -@height + @line_height
        end

        def insert_elipses(line_to_print)
          if @document.width_of(line_to_print + "...", :kerning => @kerning) < @width
            line_to_print.insert(-1, "...")
          else
            line_to_print[-3..-1] = "..." if line_to_print.length > 3
          end
        end

        def default_wrap_block
          lambda do |line, options|
            scan_pattern = /\S+|\s+/
            output = ""
            accumulated_width = 0
            line.scan(scan_pattern).each do |segment|
              segment_width = options[:document].width_of(segment,
                               :size => options[:size], :kerning => options[:kerning])
        
              if accumulated_width + segment_width <= options[:width]
                accumulated_width += segment_width
                output << segment
              else
                # if the line contains white space, don't split the
                # final word that doesn't fit, just return what fits nicely
                break if output =~ /\s/
                
                # if there is no white space on the curren tline, then just
                # print whatever part of the last segment that will fit on the
                # line
                begin
                  segment.unpack("U*").each do |char_int|
                    char = [char_int].pack("U")
                    accumulated_width += options[:document].width_of(char,
                                          :size => options[:size], :kerning => options[:kerning])
                    break if accumulated_width >= options[:width]
                    output << char
                  end
                rescue
                  segment.each_char do |char|
                    accumulated_width += options[:document].width_of(char,
                                          :size => options[:size], :kerning => options[:kerning])
                    break if accumulated_width >= options[:width]
                    output << char
                  end
                end
              end
            end
            output
          end
        end
      end
    end
  end
end


class String
  def first_line
    self.each_line { |line| return line }
  end
end
