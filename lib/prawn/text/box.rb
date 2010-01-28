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
    # <tt>:leading</tt>:: <tt>number</tt>. Additional space between lines [0]
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
    # <tt>:wrap_block</tt>:: <tt>proc</tt>. A proc used for custom line
    #                        wrapping. The proc must accept a single
    #                        <tt>line</tt> of text and an <tt>options</tt> hash
    #                        and return the string from that single line that
    #                        can fit on the line under the conditions defined by
    #                        <tt>options</tt>. If omitted, the default wrapping
    #                        proc is used. The options hash passed into the
    #                        wrap_block proc includes the following options: 
    #                        <tt>:width</tt>:: the width available for the
    #                                          current line of text
    #                        <tt>:document</tt>:: the pdf object
    #                        <tt>:kerning</tt>:: boolean
    #                        <tt>:size</tt>:: the font size
    #
    # Returns any text that did not print under the current settings
    #
    def text_box(text, options)
      Text::Box.new(text, options.merge(:document => self)).render
    end

    # Generally, one would use the text_box convenience method. However, using
    # Text::Box.new in conjunction with render() enables one to do look-ahead
    # calculations prior to placing text on the page, or to determine how much
    # vertical space was consumed by the printed text
    #
    class Box
      
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
      def initialize(text, options={})
        @inked          = false
        Prawn.verify_options(valid_options, options)
        options         = options.dup
        @overflow       = options[:overflow] || :truncate
        # we'll be messing with the strings encoding, don't change the user's
        # original string
        @text_to_print  = text.dup
        @text           = nil
        
        @document       = options[:document]
        @at             = options[:at] ||
                          [@document.bounds.left, @document.bounds.top]
        @width          = options[:width] ||
                          @document.bounds.right - @at[0]
        @height         = options[:height] ||
                          @at[1] - @document.bounds.bottom
        @center         = [@at[0] + @width * 0.5, @at[1] + @height * 0.5]
        @align          = options[:align] || :left
        @vertical_align = options[:valign] || :top
        @leading        = options[:leading] || 0

        if @overflow == :expand
          # if set to expand, then we simply set the bottom
          # as the bottom of the document bounds, since that
          # is the maximum we should expand to
          @height = @at[1] - @document.bounds.bottom
          @overflow = :truncate
        end
        @min_font_size  = options[:min_font_size] || 5
        @wrap_block     = options [:wrap_block] || default_wrap_block
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
        unprinted_text = ''
        @document.save_font do
          process_options

          unless @document.skip_encoding
            @document.font.normalize_encoding!(@text_to_print)
          end

          @document.font_size(@font_size) do
            shrink_to_fit if @overflow == :shrink_to_fit
            process_vertical_alignment
            @inked = true unless flags[:dry_run]
            unprinted_text = _render(@text_to_print)
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

      def valid_options
        Text::VALID_TEXT_OPTIONS.dup.concat([:at, :height, :width,
                                             :align, :valign,
                                             :overflow, :min_font_size,
                                             :wrap_block,
                                             :leading,
                                             :document])
      end

      def process_vertical_alignment
        return if @vertical_align == :top
        _render(@text_to_print)
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
      def shrink_to_fit
        while (unprinted_text = _render(@text_to_print)).length > 0 &&
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

      def _render(remaining_text)
        @line_height = @document.font.height
        @descender   = @document.font.descender
        @ascender    = @document.font.ascender
        @baseline_y  = -@ascender
        
        printed_text = []
        
        while remaining_text &&
              remaining_text.length > 0 &&
              @baseline_y.abs + @descender <= @height
          line_to_print = @wrap_block.call(remaining_text.first_line,
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
          x = @center[0] - @width * 0.5
        when :center
          line_width = @document.width_of(line_to_print, :kerning => @kerning)
          x = @center[0] - line_width * 0.5
        when :right
          line_width = @document.width_of(line_to_print, :kerning => @kerning)
          x = @center[0] + @width * 0.5 - line_width
        end
        
        y = @at[1] + @baseline_y
        
        if @inked
          @document.text_at(line_to_print, :at => [x, y],
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

      def default_wrap_block
        lambda do |line, options|
          scan_pattern = options[:document].font.unicode? ? /\S+|\s+/ : /\S+|\s+/n
          space_scan_pattern = options[:document].font.unicode? ? /\s/ : /\s/n
          output = ""
          accumulated_width = 0
          line.scan(scan_pattern).each do |segment|
            segment_width = options[:document].width_of(segment,
                                                  :size => options[:size],
                                                  :kerning => options[:kerning])
            
            if accumulated_width + segment_width <= options[:width]
              accumulated_width += segment_width
              output << segment
            else
              # if the line contains white space, don't split the
              # final word that doesn't fit, just return what fits nicely
              break if output =~ space_scan_pattern
              
              # if there is no white space on the current line, then just
              # print whatever part of the last segment that will fit on the
              # line
              begin
                segment.unpack("U*").each do |char_int|
                  char = [char_int].pack("U")
                  accumulated_width += options[:document].width_of(char,
                                                  :size => options[:size],
                                                  :kerning => options[:kerning])
                  break if accumulated_width >= options[:width]
                  output << char
                end
              rescue
                # not valid unicode
                segment.each_char do |char|
                  accumulated_width += options[:document].width_of(char,
                                                  :size => options[:size],
                                                  :kerning => options[:kerning])
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
