# encoding: utf-8

# text.rb : Implements PDF text primitives
#
# Copyright May 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require "zlib"
require "prawn/text/box"

module Prawn
  module Text
    attr_reader :text_options
    attr_reader :skip_encoding

    ruby_18 { $KCODE="U" }

    # Gets height of text in PDF points. See text() for valid options.
    #
    def height_of(string, options={})
      box = Text::Box.new(string,
                          options.merge(:height   => 100000000,
                                        :document => self))
      box.render(:dry_run => true)
      height = box.height - box.descender
      height += box.line_height + box.leading - box.ascender # if final_gap
      height
    end

    # If you want text to flow onto a new page or between columns, this is the
    # method to use. If, instead, if you want to place bounded text outside of
    # the flow of a document (for captions, labels, charts, etc.), use Text::Box
    # or its convenience method text_box.
    # 
    # Draws text on the page. If a point is specified via the <tt>:at</tt>
    # option the text will begin exactly at that point, and the string is
    # assumed to be pre-formatted to properly fit the page.
    # 
    #   pdf.text "Hello World", :at => [100,100]
    #   pdf.text "Goodbye World", :at => [50,50], :size => 16
    #
    # When <tt>:at</tt> is not specified, Prawn attempts to wrap the text to
    # fit within your current bounding box (or margin_box if no bounding box
    # is being used ). Text will flow onto the next page when it reaches
    # the bottom of the bounding box. Text wrap in Prawn does not re-flow
    # linebreaks, so if you want fully automated text wrapping, be sure to
    # remove newlines before attempting to draw your string.  
    #
    #   pdf.text "Will be wrapped when it hits the edge of your bounding box"
    #   pdf.text "This will be centered", :align => :center
    #   pdf.text "This will be right aligned", :align => :right
    #
    # If your font contains kerning pairs data that Prawn can parse, the 
    # text will be kerned by default.  You can disable this feature by passing
    # <tt>:kerning => false</tt>.
    #
    # === Text Positioning Details:
    #
    # When using the :at parameter, Prawn will position your text by the
    # left-most edge of its baseline, and flow along a single line.  (This
    # means that :align will not work)
    # 
    # Otherwise, the text is positioned at font.ascender below the baseline,
    # making it easy to use this method within bounding boxes and spans.
    #
    # == Rotation
    #
    # Text can be rotated before it is placed on the canvas by specifying the
    # <tt>:rotate</tt> option with a given angle. Rotation occurs counter-clockwise.
    # Note that <tt>:rotate</tt> is only compatible when using the <tt>:at</tt> option
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
    # === Additional options available when <tt>:at</tt> option is provided
    #
    # <tt>:at</tt>:: <tt>[x, y]</tt>. The position at which to start the text
    # <tt>:rotate</tt>:: <tt>number</tt>. The angle to which to rotate text
    #
    # === Additional options available when <tt>:at</tt> option is omitted
    #
    # <tt>:align</tt>:: <tt>:left</tt>, <tt>:center</tt>, or <tt>:right</tt>.
    #                   Alignment within the bounding box [:left]
    # <tt>:valign</tt>:: <tt>:top</tt>, <tt>:center</tt>, or <tt>:bottom</tt>.
    #                    Vertical alignment within the bounding box [:top]
    # <tt>:leading</tt>:: <tt>number</tt>. Additional space between lines [0]
    # <tt>:final_gap</tt>:: <tt>boolean</tt>. If true, then the space between
    #                       each line is included below the last line;
    #                       otherwise, document.y is placed just below the
    #                       descender of the last line printed [true] 
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
    # Raises <tt>ArgumentError</tt> if both <tt>:at</tt> and <tt>:align</tt>
    # options included
    #
    # Raises <tt>ArgumentError</tt> if <tt>:rotate</tt> option included, but
    # <tt>:at</tt> option omitted
    #
    def text(text, options={})
      # we might modify the options. don't change the user's hash
      options = options.dup
      if options[:at]
        inspect_options_for_text_at(options)
        # we'll be messing with the strings encoding, don't change the user's
        # original string
        text = text.to_s.dup
        options = @text_options.merge(options)
        save_font do
          process_text_options(options)
          font.normalize_encoding!(text) unless @skip_encoding
          font_size(options[:size]) { text_at(text, options) }
        end
      else
        remaining_text = fill_text_box(text, options)
        while remaining_text.length > 0
          @bounding_box.move_past_bottom
          previous_remaining_text = remaining_text
          remaining_text = fill_text_box(remaining_text, options)
          break if remaining_text == previous_remaining_text
        end
      end
    end

    # Low level text placement method. All font and size alterations
    # should already be set
    #
    def text_at(text, options)
      x,y = translate(options[:at])
      add_text_content(text,x,y,options)
    end

    # These should be used as a base. Extensions may build on this list
    VALID_TEXT_OPTIONS = [:kerning, :size, :style]

    # Low level call to set the current font style and extract text options from
    # an options hash. Should be called from within a save_font block
    #
    def process_text_options(options)
      if options[:style]
        raise "Bad font family" unless font.family
        font(font.family, :style => options[:style])
      end

      # must compare against false to keep kerning on as default
      unless options[:kerning] == false
        options[:kerning] = font.has_kerning_data?
      end

      options[:size] ||= font_size
    end

    private

    def fill_text_box(text, options)
      final_gap = inspect_options_for_text_box(options)
      bottom = @bounding_box.stretchy? ? @margin_box.absolute_bottom :
                                         @bounding_box.absolute_bottom

      options[:height] = y - bottom
      options[:width] = bounds.width
      options[:at] = [@bounding_box.left_side - @bounding_box.absolute_left,
                      y - @bounding_box.absolute_bottom]

      box = Text::Box.new(text, options)
      remaining_text = box.render

      self.y -= box.height - box.descender
      self.y -= box.line_height + box.leading - box.ascender if final_gap

      remaining_text
    end

    def inspect_options_for_text_at(options)
      if options[:align]
        raise ArgumentError, "The :align option does not work with :at"
      end
      valid_options = VALID_TEXT_OPTIONS.dup.concat([:at, :rotate])
      Prawn.verify_options(valid_options, options)
    end

    def inspect_options_for_text_box(options)
      if options[:rotate]
        raise ArgumentError, "Rotated text may only be used with :at"
      end
      options.merge!(:document => self)
      final_gap = options[:final_gap].nil? ? true : options[:final_gap]
      options.delete(:final_gap)
      final_gap
    end

    def move_text_position(dy)
      bottom = @bounding_box.stretchy? ? @margin_box.absolute_bottom :
                                         @bounding_box.absolute_bottom

      @bounding_box.move_past_bottom if (y - dy) < bottom

      self.y -= dy
    end

    def add_text_content(text, x, y, options)
      chunks = font.encode_text(text,options)

      add_content "\nBT"

      if options[:rotate]
        rad = options[:rotate].to_i * Math::PI / 180
        arr = [ Math.cos(rad), Math.sin(rad), -Math.sin(rad), Math.cos(rad), x, y ]
        add_content "%.3f %.3f %.3f %.3f %.3f %.3f Tm" % arr
      else
        add_content "#{x} #{y} Td"
      end

      chunks.each do |(subset, string)|
        font.add_to_current_page(subset)
        add_content "/#{font.identifier_for(subset)} #{font_size} Tf"

        operation = options[:kerning] && string.is_a?(Array) ? "TJ" : "Tj"
        add_content Prawn::PdfObject(string, true) << " " << operation
      end

      add_content "ET\n"
    end
  end
end
