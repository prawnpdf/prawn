# encoding: utf-8

# text/box.rb : Implements text boxes
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
    # <tt>:rotate</tt>:: <tt>number</tt>. The angle to rotate the text
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
    #                      controls the behavior when 
    #                      the amount of text exceeds the available space
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
    #                        object must have a wrap_line method that accept a
    #                        single <tt>line</tt> of text and an
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
    #                        <tt>:size</tt>:: the font size
    #
    # Returns any text that did not print under the current settings.
    #
    # NOTE: if an AFM font is used, then the returned text is encoded in
    # WinAnsi. Subsequent calls to text_box that pass this returned text back
    # into text box must include a :skip_encoding => true option. This is
    # unnecessary when using TTF fonts because those operate on UTF-8 encoding.
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
         :leading, :document, :rotate, :rotate_around,
         :single_line, :skip_encoding]


      
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
        @rotate          = options[:rotate] || 0
        @rotate_around   = options[:rotate_around] || :upper_left
        @single_line     = options[:single_line]
        @skip_encoding   = options[:skip_encoding] || @document.skip_encoding

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

          unless @skip_encoding
            @document.font.normalize_encoding!(string)
          end

          @document.font_size(@font_size) do
            shrink_to_fit(string) if @overflow == :shrink_to_fit
            process_vertical_alignment(string)
            @inked = true unless flags[:dry_run]
            if @rotate != 0 && @inked
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

        @document.rotate(@rotate, :origin => [x, y]) do
          unprinted_text = _render(string)
        end
        unprinted_text
      end

      def _render(remaining_text)
        @line_height = @document.font.height
        @descender   = @document.font.descender
        @ascender    = @document.font.ascender
        @baseline_y  = -@ascender
        
        printed_text = []
        
        while remaining_text &&
              remaining_text.length > 0 &&
              @baseline_y.abs + @descender <= @height
          line_to_print = @line_wrap.wrap_line(remaining_text.first_line,
                                                 :document => @document,
                                                 :kerning => @kerning,
                                                 :size => @font_size,
                                                 :width => @width)

          if line_to_print.empty? && remaining_text.length > 0
            raise Errors::CannotFit
          end

          remaining_text = remaining_text.slice(line_to_print.length..
                                                remaining_text.length)
          print_ellipses = (@overflow == :ellipses && last_line? &&
                            remaining_text.length > 0)
          printed_text << print_line(line_to_print, print_ellipses)
          @baseline_y -= (@line_height + @leading)
          break if @single_line
        end

        @text = printed_text.join("\n") if @inked
          
        remaining_text
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
                            :size => @font_size, :kerning => @kerning)
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

    class LineWrap
      def wrap_line(line, options)
        @document = options[:document]
        @size = options[:size]
        @kerning = options[:kerning]
        @width = options[:width]
        @accumulated_width = 0
        @output = ""

        scan_pattern = @document.font.unicode? ? /\S+|\s+/ : /\S+|\s+/n
        space_scan_pattern = @document.font.unicode? ? /\s/ : /\s/n

        line.scan(scan_pattern).each do |segment|
          # yes, this block could be split out into another method, but it is
          # called on every word printed, so I'm keeping it here for speed

          segment_width = @document.width_of(segment,
                                             :size => @size,
                                             :kerning => @kerning)

          if @accumulated_width + segment_width <= @width
            @accumulated_width += segment_width
            @output << segment
          else
            # if the line contains white space, don't split the
            # final word that doesn't fit, just return what fits nicely
            break if @output =~ space_scan_pattern
            wrap_by_char(segment)
            break
          end
        end
        @output
      end

      private

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
        @accumulated_width += @document.width_of(char,
                                                 :size => @size,
                                                 :kerning => @kerning)
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
