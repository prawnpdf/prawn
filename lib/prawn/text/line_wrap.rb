# encoding: utf-8

# text/line_wrap.rb : Implements individual line wrapping
#
# Copyright January 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Text
    
    class LineWrap

      def width
        @accumulated_width || 0
      end

      def space_count
        @space_count
      end

      def consumed_char_count
        @consumed_char_count
      end

      def wrap_line(line, options)
        @document = options[:document]
        @kerning = options[:kerning]
        @width = options[:width]
        @accumulated_width = 0
        @output = ""
        @scan_pattern = @document.font.unicode? ? /\S+|\s+/ : /\S+|\s+/n
        @space_scan_pattern = @document.font.unicode? ? /\s/ : /\s/n

        _wrap_line(line)

        @space_count = @output.count(" ")
        @output
      end

      private

      def _wrap_line(line)
        line.scan(@scan_pattern).each do |segment|
          segment_width = @document.width_of(segment, :kerning => @kerning)

          if @accumulated_width + segment_width <= @width
            @accumulated_width += segment_width
            @output += segment
          else
            # if the line contains white space, don't split the
            # final word that doesn't fit, just return what fits nicely
            wrap_by_char(segment) unless @output =~ @space_scan_pattern
            break
          end
        end

        raise Errors::CannotFit if @output.empty? && !line.strip.empty?

        finalize_line
      end

      def finalize_line
        @consumed_char_count = @output.length
        strip_trailing_whitespace
      end

      def strip_trailing_whitespace
        @output.strip!
        deleted_spaces = @consumed_char_count - @output.length
        if deleted_spaces > 0
          @accumulated_width -= @document.width_of(" " * deleted_spaces,
                                                   :kerning => @kerning)
        end
      end

      def wrap_by_char(segment)
        if @document.font.unicode?
          segment.unpack("U*").each do |char_int|
            return unless append_char([char_int].pack("U"))
          end
        else
          segment.each_char do |char|
            return unless append_char(char)
          end
        end
      end

      def append_char(char)
        char_width = @document.width_of(char, :kerning => @kerning)
        @accumulated_width += char_width

        if @accumulated_width >= @width
          false
        else
          @output << char
          true
        end
      end
    end

  end
end
