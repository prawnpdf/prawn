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

    VALID_TEXT_OPTIONS = [:at, :kerning, :leading,
                          :rotate, :size, :style]

    # Draws text on the page. If a point is specified via the +:at+
    # option the text will begin exactly at that point, and the string is
    # assumed to be pre-formatted to properly fit the page.
    # 
    #   pdf.text "Hello World", :at => [100,100]
    #   pdf.text "Goodbye World", :at => [50,50], :size => 16
    #
    # When +:at+ is not specified, Prawn attempts to wrap the text to
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
    #  Wrapping is done by splitting words by spaces by default.  If your text
    #  does not contain spaces, you can wrap based on characters instead:
    #
    #   pdf.text "This will be wrapped by character", :wrap => :character  
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
    #
    # Otherwise, the text is positioned at font.ascender below the baseline,
    # making it easy to use this method within bounding boxes and spans.
    #
    # == Rotation
    #
    # Text can be rotated before it is placed on the canvas by specifying the
    # +:rotate+ option with a given angle. Rotation occurs counter-clockwise.
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
    def text(text,options={})
      if options[:at]
        if options[:align]
          raise ArgumentError, "The :align option does not work with :at"
        end
        Prawn.verify_options(VALID_TEXT_OPTIONS, options)
        # we'll be messing with the strings encoding, don't change the user's
        # original string
        text = text.to_s.dup
        save_font do
          options = @text_options.merge(options)
          process_text_options(options)

          font.normalize_encoding!(text) unless @skip_encoding
          font_size(options[:size]) { text_at(text, options) }
        end
      else
        if options[:rotate]
          raise ArgumentError, "Rotated text may only be used with :at"
        end
        # Don't modify the user's options hash
        options = options.clone
        bottom = @bounding_box.stretchy? ? @margin_box.absolute_bottom :
          @bounding_box.absolute_bottom
        options[:height] = y - bottom
        remaining_text = text_box(text, options)
        while remaining_text.length > 0
          @bounding_box.move_past_bottom
          options[:height] = nil
          previous_remaining_text = remaining_text
          remaining_text = text_box(text, options)
          break if remaining_text == previous_remaining_text
        end
      end
    end

    # Low level text placement method. All font and size alterations
    # should already be set
    def text_at(text, options)
      x,y = translate(options[:at])
      add_text_content(text,x,y,options)
    end

    def process_text_options(options)
      if options[:style]
        raise "Bad font family" unless font.family
        font(font.family,:style => options[:style])
      end

      # must compare against false to keep kerning on as default
      unless options[:kerning] == false
        options[:kerning] = font.has_kerning_data?
      end

      options[:size] ||= font_size
    end

    private

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
