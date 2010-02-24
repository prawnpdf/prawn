module Prawn
  module Text
    
    class LineWrap

      def width
        @accumulated_width || 0
      end

      def wrap_line(options)
        @document = options[:document]
        @kerning = options[:kerning]
        @width = options[:width]
        @line = options[:line]
        @accumulated_width = 0
        @fragment_width = 0
        @output = ""
        @scan_pattern = @document.font.unicode? ? /\S+|\s+/ : /\S+|\s+/n
        @space_scan_pattern = @document.font.unicode? ? /\s/ : /\s/n

        _wrap_line
        
        @output
      end

      private

      def _wrap_line
        @line.scan(@scan_pattern).each do |segment|
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
        @fragment_width += char_width

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
