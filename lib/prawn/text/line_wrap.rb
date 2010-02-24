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
        @inline_format = options[:inline_format]
        @accumulated_width = 0
        @fragment_width = 0
        @output = ""
        scan_pattern = @document.font.unicode? ? /\S+|\s+/ : /\S+|\s+/n
        space_scan_pattern = @document.font.unicode? ? /\s/ : /\s/n

        if @inline_format
          formatted_wrap_line(scan_pattern, space_scan_pattern)
        else
          unformatted_wrap_line(options[:line], scan_pattern, space_scan_pattern)
        end
        
        @output
      end

      private

      def unformatted_wrap_line(line, scan_pattern, space_scan_pattern)
        line.scan(scan_pattern).each do |segment|
          segment_width = @document.width_of(segment, :kerning => @kerning)

          if @accumulated_width + segment_width <= @width
            @accumulated_width += segment_width
            @output += segment
          else
            # if the line contains white space, don't split the
            # final word that doesn't fit, just return what fits nicely
            wrap_by_char(segment) unless @output =~ space_scan_pattern
            break
          end
        end
      end

      def formatted_wrap_line(scan_pattern, space_scan_pattern)
        @inline_format.initialize_line
        @line_output = ""
        while fragment = @inline_format.next_string
          @output = ""
          fragment.lstrip! if @line_output.empty? && fragment != "\n"
          @fragment_width = 0
          if !add_formatted_fragment_to_line(fragment, scan_pattern, space_scan_pattern)
            fragment_finished(fragment, true)
            break
          end
          
          preview = @inline_format.preview_next_string
          fragment_finished(fragment, preview == "\n" || preview.nil?)
        end
        @output = @line_output
      end

      def fragment_finished(fragment, finished_line)
        if fragment == "\n"
          set_last_formatted_fragment_size_data
        else
          update_formatted_output_based_on_last_fragment(fragment, finished_line)
          @line_output += @output
          set_last_formatted_fragment_size_data
        end
      end

      def update_formatted_output_based_on_last_fragment(fragment, finished_line)
        remaining_text = fragment.slice(@output.length..fragment.length)
        @output.rstrip! if finished_line
        @fragment_width = single_format_text_width(@output)
        @inline_format.update_last_string(@output, remaining_text)
      end

      def single_format_text_width(text)
        raise "Bad font family" unless @document.font.family
        width = 0
        apply_current_font_settings do
          width = @document.width_of(text, :kerning => @kerning)
        end
        width
      end

      # returns true iff all text was printed without running into the end of
      # the line
      #
      def add_formatted_fragment_to_line(fragment, scan_pattern, space_scan_pattern)
        return false if fragment == "\n"
        fragment.scan(scan_pattern).each do |segment|
          raise "Bad font family" unless @document.font.family
          apply_current_font_settings do
            segment_width = @document.width_of(segment, :kerning => @kerning)

            if @accumulated_width + segment_width <= @width
              @accumulated_width += segment_width
              @fragment_width += segment_width
              @output += segment
            else
              # if the line contains white space, don't split the
              # final word that doesn't fit, just return what fits nicely
              unless (@line_output + @output) =~ space_scan_pattern
                wrap_by_char(segment)
              end
              return false
            end
          end
        end
        true
      end

      def set_last_formatted_fragment_size_data
        apply_current_font_settings do
          @inline_format.set_last_string_size_data(
                                     :width => @fragment_width,
                                     :line_height => @document.font.height,
                                     :descender => @document.font.descender,
                                     :ascender => @document.font.ascender
                                                   )
        end
      end

      def apply_current_font_settings
        @document.font(@document.font.family,
                       :style => @inline_format.current_font_style) do
          @document.font_size(@inline_format.current_font_size || @document.font_size) do
            yield
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
