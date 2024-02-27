# frozen_string_literal: true

require_relative 'formatted/box'

module Prawn
  module Text # rubocop: disable Style/Documentation
    # @group Stable API

    # Draws the requested text into a box.
    #
    # When the text overflows the rectangle, you shrink to fit, or truncate the
    # text. Text boxes are independent of the document y position.
    #
    # #### Encoding
    #
    # Note that strings passed to this function should be encoded as UTF-8. If
    # you get unexpected characters appearing in your rendered document, check
    # this.
    #
    # If the current font is a built-in one, although the string must be encoded
    # as UTF-8, only characters that are available in WinAnsi are allowed.
    #
    # If an empty box is rendered to your PDF instead of the character you
    # wanted it usually means the current font doesn't include that character.
    #
    # @param string [String]
    # @param options [Hash{Symbol => any}]
    # @option options :kerning [Boolean] (value of document.default_kerning?)
    #   Whether or not to use kerning (if it is available with the current
    #   font).
    # @option options :size [Number] (current font size)
    #   The font size to use.
    # @option options :character_spacing [Number] (0)
    #   The amount of space to add to or remove from the default character
    #   spacing.
    # @option options :disable_wrap_by_char [Boolean] (false)
    #   Whether or not to prevent mid-word breaks when text does not fit in box.
    # @option options :mode [Symbol] (:fill)
    #   The text rendering mode. See documentation for
    #   {Prawn::Document#text_rendering_mode} for a list of valid options.
    # @option option :style [Symbol] (current style)
    #   The style to use. The requested style must be part of the current font
    #   family.
    # @option option :at [Array(Number, Number)] (bounds top left corner)
    #   The upper left corner of the box.
    # @option options :width [Number] (bounds.right - at[0])
    #   The width of the box.
    # @option options :height [Number] (default_height())
    #   The height of the box.
    # @option options :direction [:ltr, :rtl] (value of document.text_direction)
    #   Direction of the text (left-to-right or right-to-left).
    # @option options :fallback_fonts [Array<String>]
    #   An array of font names. Each name must be the name of an AFM font or the
    #   name that was used to register a family of external fonts (see
    #   {Prawn::Document#font_families}). If present, then each glyph will be
    #   rendered using the first font that includes the glyph, starting with the
    #   current font and then moving through `:fallback_fonts`.
    # @option options :align [:left, :center, :right, :justify]
    #   (:left if direction is :ltr, :right if direction is :rtl)
    #   Alignment within the bounding box.
    # @option options :valign [:top, :center, :bottom] (:top)
    #   Vertical alignment within the bounding box.
    # @option options :rotate [Number]
    #   The angle to rotate the text.
    # @option options :rotate_around
    #   [:center, :upper_left, :upper_right, :lower_right, :lower_left]
    #   (:upper_left)
    #   The point around which to rotate the text.
    # @option options :leading [Number] (value of document.default_leading)
    #   Additional space between lines.
    # @option options :single_line [Boolean] (false)
    #   If true, then only the first line will be drawn.
    # @option options :overflow [:truncate, :shrink_to_fit, :expand] (:truncate)
    #   This controls the behavior when the amount of text exceeds the available
    #   space.
    # @option options :min_font_size [Number] (5)
    #   The minimum font size to use when `:overflow` is set to `:shrink_to_fit`
    #   (that is the font size will not be reduced to less than this value, even
    #   if it means that some text will be cut off).
    # @return [String] Any text that did not print under the current settings.
    # @raise [Prawn::Errors::CannotFit]
    #   If not wide enough to print any text.
    def text_box(string, options = {})
      options = options.dup
      options[:document] = self

      box =
        if options[:inline_format]
          p = options.delete(:inline_format)
          p = [] unless p.is_a?(Array)
          array = text_formatter.format(string, *p)
          Text::Formatted::Box.new(array, options)
        else
          Text::Box.new(string, options)
        end

      box.render
    end

    # @group Experimental API

    # Text box.
    #
    # Generally, one would use the {Prawn::Text#text_box} convenience method.
    # However, using {Prawn::Text::Box#initialize Box.new} in conjunction with
    # `render(dry_run: true)` enables one to do calculations prior to placing
    # text on the page, or to determine how much vertical space was consumed by
    # the printed text.
    class Box < Prawn::Text::Formatted::Box
      # @param string [String]
      # @param options [Hash{Symbol => any}]
      # @option options :document [Prawn::Document] Owning document.
      # @option options :kerning [Boolean] (value of document.default_kerning?)
      #   Whether or not to use kerning (if it is available with the current
      #   font).
      # @option options :size [Number] (current font size)
      #   The font size to use.
      # @option options :character_spacing [Number] (0)
      #   The amount of space to add to or remove from the default character
      #   spacing.
      # @option options :disable_wrap_by_char [Boolean] (false)
      #   Whether or not to prevent mid-word breaks when text does not fit in box.
      # @option options :mode [Symbol] (:fill)
      #   The text rendering mode. See documentation for
      #   {Prawn::Document#text_rendering_mode} for a list of valid options.
      # @option option :style [Symbol] (current style)
      #   The style to use. The requested style must be part of the current font
      #   family.
      # @option option :at [Array(Number, Number)] (bounds top left corner)
      #   The upper left corner of the box.
      # @option options :width [Number] (bounds.right - at[0])
      #   The width of the box.
      # @option options :height [Number] (default_height())
      #   The height of the box.
      # @option options :direction [:ltr, :rtl] (value of document.text_direction)
      #   Direction of the text (left-to-right or right-to-left).
      # @option options :fallback_fonts [Array<String>]
      #   An array of font names. Each name must be the name of an AFM font or the
      #   name that was used to register a family of external fonts (see
      #   {Prawn::Document#font_families}). If present, then each glyph will be
      #   rendered using the first font that includes the glyph, starting with the
      #   current font and then moving through `:fallback_fonts`.
      # @option options :align [:left, :center, :right, :justify]
      #   (:left if direction is :ltr, :right if direction is :rtl)
      #   Alignment within the bounding box.
      # @option options :valign [:top, :center, :bottom] (:top)
      #   Vertical alignment within the bounding box.
      # @option options :rotate [Number]
      #   The angle to rotate the text.
      # @option options :rotate_around
      #   [:center, :upper_left, :upper_right, :lower_right, :lower_left]
      #   (:upper_left)
      #   The point around which to rotate the text.
      # @option options :leading [Number] (value of document.default_leading)
      #   Additional space between lines.
      # @option options :single_line [Boolean] (false)
      #   If true, then only the first line will be drawn.
      # @option options :overflow [:truncate, :shrink_to_fit, :expand] (:truncate)
      #   This controls the behavior when the amount of text exceeds the available
      #   space.
      # @option options :min_font_size [Number] (5)
      #   The minimum font size to use when `:overflow` is set to `:shrink_to_fit`
      #   (that is the font size will not be reduced to less than this value, even
      #   if it means that some text will be cut off).
      def initialize(string, options = {})
        super([{ text: string }], options)
      end

      # Render text to the document based on the settings defined in
      # constructor.
      #
      # In order to facilitate look-ahead calculations, this method accepts
      # a `dry_run: true` option. If provided, then everything is executed as if
      # rendering, with the exception that nothing is drawn on the page.  Useful
      # for look-ahead computations of height, unprinted text, etc.
      #
      # @param flags [Hash{Symbol => any}]
      # @option flags :dry_run [Boolean] (false)
      #   Do not draw the text. Everything else is done.
      # @return [String]
      #   Any text that did not print under the current settings.
      # @raise [Prawn::Text::Formatted::Arranger::BadFontFamily]
      #   If no font family is defined for the current font.
      # @raise [Prawn::Errors::CannotFit]
      #   If not wide enough to print any text.
      def render(flags = {})
        leftover = super(flags)
        leftover.map { |hash| hash[:text] }.join
      end
    end
  end
end
