# encoding: utf-8

# text/rectangle.rb : Implements text boxes
#
# Copyright November 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Text

    # Draws the requested text into a box. When the text overflows
    # the rectangle, you can display ellipses, shrink to fit, or
    # truncate the text. Text boxes are independent of the document
    # y position.
    #
    # == Encoding
    #
    # Note that strings passed to this function should be encoded as UTF-8.
    # If you get unexpected characters appearing in your rendered document, 
    # check this.
    #
    # If the current font is a built-in one, although the string must be
    # encoded as UTF-8, only characters that are available in WinAnsi
    # are allowed.
    #
    # If an empty box is rendered to your PDF instead of the character you 
    # wanted it usually means the current font doesn't include that character.
    #
    # == Options (default values marked in [])
    #
    # <tt>:kerning</tt>:: <tt>boolean</tt>. Whether or not to use kerning (if it
    #                     is available with the current font) [true]
    # <tt>:size</tt>:: <tt>number</tt>. The font size to use. [current font
    #                  size]
    # <tt>:style</tt>:: The style to use. The requested style must be part of
    #                   the current font familly. [current style]
    #
    # <tt>:at</tt>:: <tt>[x, y]</tt>. The upper left corner of the box
    #                [@document.bounds.left, @document.bounds.top]
    # <tt>:width</tt>:: <tt>number</tt>. The width of the box
    #                   [@document.bounds.right - @at[0]]
    # <tt>:height</tt>:: <tt>number</tt>. The height of the box [@at[1] -
    #                    @document.bounds.bottom]
    # <tt>:align</tt>:: <tt>:left</tt>, <tt>:center</tt>, or <tt>:right</tt>.
    #                   Alignment within the bounding box [:left]
    # <tt>:valign</tt>:: <tt>:top</tt>, <tt>:center</tt>, or <tt>:bottom</tt>.
    #                    Vertical alignment within the bounding box [:top]
    # <tt>:rotation</tt>:: <tt>number</tt>. The angle to rotate the text
    # <tt>:rotate_around</tt>:: <tt>:center</tt>, <tt>:upper_left</tt>,
    #                           <tt>:upper_right</tt>, <tt>:lower_right</tt>,
    #                           or <tt>:lower_left</tt>. The point around which
    #                           to rotate the text [:upper_left]
    # <tt>:leading</tt>:: <tt>number</tt>. Additional space between lines [0]
    # <tt>:single_line</tt>:: <tt>boolean</tt>. If true, then only the first
    #                         line will be drawn [false]
    # <tt>:skip_encoding</tt>:: <tt>boolean</tt> [false]
    # <tt>:overflow</tt>:: <tt>:truncate</tt>, <tt>:shrink_to_fit</tt>,
    #                      <tt>:expand</tt>, or <tt>:ellipses</tt>. This
    #                      controls the behavior when  the amount of text
    #                      exceeds the available space. <tt>:ellipses</tt> is
    #                      not available with <tt>:inline_styling</tt>
    #                      [:truncate]
    # <tt>:min_font_size</tt>:: <tt>number</tt>. The minimum font size to use
    #                           when :overflow is set to :shrink_to_fit (that is
    #                           the font size will not be 
    #                           reduced to less than this value, even if it
    #                           means that some text will be cut off). [5]
    # <tt>:line_wrap</tt>:: <tt>object</tt>. An object used for custom line
    #                        wrapping on a case by case basis. Note that if you
    #                        want to change wrapping document-wide, do
    #                        pdf.default_line_wrap = MyLineWrap.new. Your custom
    #                        object must have a wrap_line method that accepts an
    #                        <tt>options</tt> hash and returns the string from 
    #                        that single line that can fit on the line under 
    #                        the conditions defined by <tt>options</tt>. If 
    #                        omitted, the line wrap object is used.
    #                        The options hash passed into the wrap_object proc
    #                        includes the following options:
    #                        <tt>:width</tt>:: the width available for the
    #                                          current line of text
    #                        <tt>:document</tt>:: the pdf object
    #                        <tt>:kerning</tt>:: boolean
    #                        <tt>:line</tt>:: the line of text to print. Note
    #                        that this option is not provided when inline
    #                        formatting is being used
    #                        <tt>:inline_format</tt>:: an InlineFormatter
    #                        object. Note that this is only provided when
    #                        inline formatting is being used
    #                        Note that you need not support both line and
    #                        inline_format options if you intend on using your
    #                        custom word wrap object only with formatted or only
    #                        with unformatted text
    #
    #                        The line wrap object should have a <tt>width</tt>
    #                        method that returns the width of the last line
    #                        printed
    #
    # Returns any text that did not print under the current settings.
    # NOTE: if an AFM font is used, then the returned text is encoded in
    # WinAnsi. Subsequent calls to text_box that pass this returned text back
    # into text box must include a :skip_encoding => true option. This is
    # unnecessary when using TTF fonts because those operate on UTF-8 encoding.
    #
    # Raises <tt>ArgumentError</tt> if <tt>:ellipses</tt> <tt>overflow</tt>
    # option included
    # Raises <tt>Errors::CannotFit</tt> if not enough width exists to drawn even
    # a single character
    # Raises "Bad font family" if <tt>:inline_format</tt> used, but no font
    # family is defined for the current font
    #
    def text_box(string, options)
      Text::Box.new(string, options.merge(:document => self)).render
    end

    # Generally, one would use the text_box convenience method. However, using
    # Text::Box.new in conjunction with render() enables one to do look-ahead
    # calculations prior to placing text on the page, or to determine how much
    # vertical space was consumed by the printed text
    #
    class Box

      VALID_OPTIONS = Prawn::Core::Text::VALID_OPTIONS + 
        [:at, :height, :width, :align, :valign,
         :overflow, :min_font_size, :line_wrap,
         :leading, :document, :rotation, :rotate_around,
         :single_line, :skip_encoding, :inline_format]


      
      # The text that was successfully printed (or, if <tt>dry_run</tt> was
      # used, the test that would have been successfully printed)
      attr_reader :text
      # The upper left corner of the text box
      attr_reader :at
      # The line height of the last line printed
      attr_reader :line_height
      # The height of the ascender of the last line printed
      attr_reader :ascender
      # The height of the descender of the last line printed
      attr_reader :descender
      # The leading used during printing
      attr_reader :leading

      # See Prawn::Text#text_box for valid options
      #
      def initialize(string, options={})
        @inked          = false
        Prawn.verify_options(VALID_OPTIONS, options)
        options          = options.dup
        @overflow        = options[:overflow] || :truncate
        @original_string = string
        @text            = nil
        
        @document        = options[:document]
        @at              = options[:at] ||
                           [@document.bounds.left, @document.bounds.top]
        @width           = options[:width] ||
                           @document.bounds.right - @at[0]
        @height          = options[:height] ||
                           @at[1] - @document.bounds.bottom
        @align           = options[:align] || :left
        @vertical_align  = options[:valign] || :top
        @leading         = options[:leading] || 0
        @rotation        = options[:rotation] || 0
        @rotate_around   = options[:rotate_around] || :upper_left
        @single_line     = options[:single_line]
        @skip_encoding   = options[:skip_encoding] || @document.skip_encoding
        if options[:inline_format]
          if @overflow == :ellipses
            raise ArgumentError, "ellipses overflow unavailable with" +
                                 "inline formatting"
          end
          @inline_format   = InlineFormatter.new
        end


        if @overflow == :expand
          # if set to expand, then we simply set the bottom
          # as the bottom of the document bounds, since that
          # is the maximum we should expand to
          @height = @at[1] - @document.bounds.bottom
          @overflow = :truncate
        end
        @min_font_size  = options[:min_font_size] || 5
        @line_wrap    = options [:line_wrap] || @document.default_line_wrap
        @options = @document.text_options.merge(:kerning => options[:kerning],
                                                :size    => options[:size],
                                                :style   => options[:style])
      end
      
      # Render text to the document based on the settings defined in initialize.
      #
      # In order to facilitate look-ahead calculations, <tt>render</tt> accepts
      # a <tt>:dry_run => true</tt> option. If provided then everything is
      # executed as if rendering, with the exception that nothing is drawn on
      # the page. Useful for look-ahead computations of height, unprinted text,
      # etc.
      #
      # Returns any text that did not print under the current settings
      #
      def render(flags={})
        # dup because normalize_encoding changes the string
        string = @original_string.dup
        unprinted_text = ''
        @document.save_font do
          process_options

          @document.font.normalize_encoding!(string) unless @skip_encoding

          @document.font_size(@font_size) do
            shrink_to_fit(string) if @overflow == :shrink_to_fit
            process_vertical_alignment(string)
            @inked = true unless flags[:dry_run]
            if @rotation != 0 && @inked
              unprinted_text = render_rotated(string)
            else
              unprinted_text = _render(string)
            end
            @inked = false
          end
        end
        unprinted_text
      end

      # The height actually used during the previous <tt>render</tt>
      # 
      def height
        return 0 if @baseline_y.nil? || @descender.nil?
        # baseline is already pushed down one line below the current
        # line, so we need to subtract line line_height and leading,
        # but we need to add in the descender since baseline is
        # above the descender
        @baseline_y.abs + @descender - @line_height - @leading
      end

      private

      def process_vertical_alignment(string)
        return if @vertical_align == :top
        _render(string)
        case @vertical_align
        when :center
          @at[1] = @at[1] - (@height - height) * 0.5
        when :bottom
          @at[1] = @at[1] - (@height - height)
        end
        @height = height
      end

      # Decrease the font size until the text fits or the min font
      # size is reached
      def shrink_to_fit(string)
        while (unprinted_text = _render(string)).length > 0 &&
            @font_size > @min_font_size
          @font_size -= 0.5
          @document.font_size = @font_size
        end
      end

      def process_options
        # must be performed within a save_font bock because
        # document.process_text_options sets the font
        @document.process_text_options(@options)
        @font_size = @options[:size]
        @kerning   = @options[:kerning]
      end

      def render_rotated(string)
        unprinted_text = ''

        case @rotate_around
        when :center
          x = @at[0] + @width * 0.5
          y = @at[1] - @height * 0.5
        when :upper_right
          x = @at[0] + @width
          y = @at[1]
        when :lower_right
          x = @at[0] + @width
          y = @at[1] - @height
        when :lower_left
          x = @at[0]
          y = @at[1] - @height
        else
          x = @at[0]
          y = @at[1]
        end

        @document.rotate(@rotation, :origin => [x, y]) do
          unprinted_text = _render(string)
        end
        unprinted_text
      end

      def _render(string)
        if @inline_format
          render_formatted(string)
        else
          render_unformatted(string)
        end
      end

      def render_unformatted(string)
        remaining_text = string
        @line_height = @document.font.height
        @descender   = @document.font.descender
        @ascender    = @document.font.ascender
        @baseline_y  = -@ascender
        
        printed_lines = []
        
        while remaining_text &&
              remaining_text.length > 0 &&
              @baseline_y.abs + @descender <= @height
          line_to_print = @line_wrap.wrap_line(
                                             :line => remaining_text.first_line,
                                             :document => @document,
                                             :kerning => @kerning,
                                             :width => @width)

          if line_to_print.empty? && remaining_text.length > 0
            raise Errors::CannotFit
          end

          remaining_text = remaining_text.slice(line_to_print.length..
                                                remaining_text.length)
          print_ellipses = (@overflow == :ellipses && last_line? &&
                            remaining_text.length > 0)
          printed_lines << print_line(line_to_print, print_ellipses)
          @baseline_y -= (@line_height + @leading)
          break if @single_line
        end

        @text = printed_lines.join("\n") if @inked
          
        remaining_text
      end

      def render_formatted(string)
        @inline_format.tokenize_string(string)

        # these values will depend on the maximum value within a given line
        @line_height = 0
        @descender   = 0
        @ascender    = 0
        @baseline_y  = 0

        printed_lines = []

        while @inline_format.unfinished? &&
              @baseline_y.abs + @descender <= @height

          printed_fragments = []

          line_to_print = @line_wrap.wrap_line(:document => @document,
                                               :kerning => @kerning,
                                               :width => @width,
                                               :inline_format => @inline_format)
          if line_to_print.empty? && @inline_format.consumed_strings.length > 0
            raise Errors::CannotFit
          end

          @line_height = @inline_format.max_line_height
          @descender   = @inline_format.max_descender
          @ascender    = @inline_format.max_ascender
          @baseline_y  = -@ascender if @baseline_y == 0
          if @baseline_y.abs + @descender > @height
            @inline_format.repack_unretrieved_strings
            break
          end

          accumulated_width = 0
          while fragment = @inline_format.retrieve_string
            raise "Bad font family" unless @document.font.family
            @document.font(@document.font.family,
                       :style => @inline_format.last_retrieved_font_style) do
              printed_fragments << print_formatted_line(fragment,
                                                        accumulated_width,
                                                        @line_wrap.width)
            end
            accumulated_width += @inline_format.last_retrieved_width
          end
          printed_lines << printed_fragments.join("")
          @baseline_y -= (@line_height + @leading)
          break if @single_line
        end

        @text = printed_lines.join("\n") if @inked

        @inline_format.unconsumed_string
      end

      def print_line(line_to_print, print_ellipses)
        # strip so that trailing and preceding white space don't
        # interfere with alignment
        line_to_print.strip!
        
        insert_ellipses(line_to_print) if print_ellipses

        case(@align)
        when :left
          x = @at[0]
        when :center
          line_width = @document.width_of(line_to_print, :kerning => @kerning)
          x = @at[0] + @width * 0.5 - line_width * 0.5
        when :right
          line_width = @document.width_of(line_to_print, :kerning => @kerning)
          x = @at[0] + @width - line_width
        end
        
        y = @at[1] + @baseline_y
        
        if @inked
          @document.draw_text!(line_to_print, :at => [x, y],
                                              :kerning => @kerning)
        end
        
        line_to_print
      end

      def print_formatted_line(line_to_print, accumulated_width, line_width)
        case(@align)
        when :left
          x = @at[0]
        when :center
          x = @at[0] + @width * 0.5 - line_width * 0.5
        when :right
          x = @at[0] + @width - line_width
        end

        x += accumulated_width

        y = @at[1] + @baseline_y

        if @inked
          @document.draw_text!(line_to_print, :at => [x, y],
                                              :kerning => @kerning)
        end

        line_to_print
      end
      
      def last_line?
        @baseline_y.abs + @descender > @height - @line_height
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




    class InlineFormatter
      attr_reader :current_format_state
      attr_reader :consumed_strings
      attr_reader :tokens
      attr_reader :max_line_height
      attr_reader :max_descender
      attr_reader :max_ascender
      attr_reader :last_retrieved_width

      def initialize
        @retrieved_format_state = []
        @current_format_state = []
        @consumed_strings = []
        @consumed_tags = []
      end

      def tokenize_string(string)
        @max_line_height = 0
        @max_descender = 0
        @max_ascender = 0
        regex_string = "\n|<b>|</b>|<i>|</i>|<u>|</u>|<strikethrough>|" +
                       "</strikethrough>|<a[^>]*>|</a>|<color[^>]*>|</color>|[^<\n]*"
        regex = Regexp.new(regex_string, Regexp::MULTILINE)
        @tokens = string.scan(regex)
        @tokens.delete("")
        @tokens
      end

      def finished?
        @tokens.length == 0
      end

      def unfinished?
        @tokens.length > 0
      end

      def unconsumed_string
        @tokens.join("")
      end

      def repack_unretrieved_strings
        new_tokens = []
        while string = retrieve_string
          new_tokens.concat(@consumed_tags)
          new_tokens << string
        end
        new_tokens.concat(@tokens)
        @tokens = new_tokens
      end

      def next_string
        string = ""
        
        while token = @tokens.shift
          @consumed_tags << token
          case token
          when "\n", "", nil
            string = token
            @consumed_tags = []
            break
          when "<b>"
            @current_format_state << :bold
          when "<i>"
            @current_format_state << :italic
          when "<u>"
            @current_format_state << :underline
          when "<strikethrough>"
            @current_format_state << :strikethrough
          when "</b>", "</i>", "</u>", "</strikethrough>", "</a>", "</color>"
            @current_format_state.pop
          else
            if token =~ /^a[^>]*>$/
              # @current_format_state << 
            elsif token =~ /^<color[^>]*>$/
              # @current_format_state <<
            else
              string = token.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&")
              @consumed_tags.pop
              @consumed_strings << { :string => string,
                                     :format => @current_format_state.dup,
                                     :tags => @consumed_tags}
              @consumed_tags = []
              break
            end
          end
        end
        string
      end

      def set_last_string_size_data(options)
        @consumed_strings.last[:width] = options[:width]
        @max_line_height = [@max_line_height, options[:line_height]].max
        @max_descender = [@max_descender, options[:descender]].max
        @max_ascender = [@max_ascender, options[:ascender]].max
      end

      def update_last_string(printed, unprinted="")
        if printed.nil? || printed.empty? || printed =~ /^ +$/
          @consumed_strings.pop
        else
          @consumed_strings.last[:string] = printed
        end
        unless unprinted.nil? || unprinted.empty? || unprinted =~ /^ +$/
          @tokens.unshift(unprinted)
        end
      end

      def retrieve_string
        hash = @consumed_strings.shift
        if hash.nil?
          @retrieved_format_state = nil
          @last_retrieved_width = 0
          @consumed_tags = []
          nil
        else
          @retrieved_format_state = hash[:format]
          @last_retrieved_width = hash[:width]
          @consumed_tags = hash[:tags]
          hash[:string]
        end
      end

      def last_retrieved_font_style
        if @retrieved_format_state.include?(:bold) && @retrieved_format_state.include?(:italic)
          :bold_italic
        elsif @retrieved_format_state.include?(:bold)
          :bold
        elsif @retrieved_format_state.include?(:italic)
          :italic
        else
          :normal
        end
      end

      def current_font_style
        if @current_format_state.include?(:bold) && @current_format_state.include?(:italic)
          :bold_italic
        elsif @current_format_state.include?(:bold)
          :bold
        elsif @current_format_state.include?(:italic)
          :italic
        else
          :normal
        end
      end

    end


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
        line_output = ""
        finished_this_line = false
        while fragment = @inline_format.next_string
          @output = ""
          if fragment == "\n" || fragment == ""
            finished_this_line = true
          else
            fragment.lstrip! if line_output.empty?

            @fragment_width = 0
            fragment.scan(scan_pattern).each do |segment|
              raise "Bad font family" unless @document.font.family
              @document.font(@document.font.family,
                             :style => @inline_format.current_font_style) do

                segment_width = @document.width_of(segment, :kerning => @kerning)

                if @accumulated_width + segment_width <= @width
                  @accumulated_width += segment_width
                  @fragment_width += segment_width
                  @output += segment
                else
                  # if the line contains white space, don't split the
                  # final word that doesn't fit, just return what fits nicely
                  unless (line_output + @output) =~ space_scan_pattern
                    wrap_by_char(segment)
                  end
                  finished_this_line = true
                  break
                end
              end
            end
          end
          unless @output.empty?
            @output.rstrip! if finished_this_line || @inline_format.finished?
            remaining_text = fragment.slice(@output.length..fragment.length)
            raise "Bad font family" unless @document.font.family
            @document.font(@document.font.family,
                           :style => @inline_format.current_font_style) do
              @fragment_width = @document.width_of(@output, :kerning => @kerning)
            end
            @inline_format.update_last_string(@output, remaining_text)
            line_output += @output
          end
          set_last_string_size_data
          break if finished_this_line
        end
        @output = line_output
      end

      def set_last_string_size_data
        @inline_format.set_last_string_size_data(:width => @fragment_width,
                                                 :line_height => @document.font.height,
                                                 :descender => @document.font.descender,
                                                 :ascender => @document.font.ascender)
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
