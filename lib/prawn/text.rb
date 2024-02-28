# frozen_string_literal: true

require 'zlib'

require_relative 'text/formatted'
require_relative 'text/box'

module Prawn
  # PDF text primitives.
  module Text
    include PDF::Core::Text
    include Prawn::Text::Formatted

    # No-Break Space
    NBSP = "\u00A0"

    # Zero Width Space (indicate word boundaries without a space)
    ZWSP = "\u200B"

    # Soft Hyphen (invisible, except when causing a line break)
    SHY = "\u00AD"

    # @group Stable API

    # Draws text on the page.
    #
    # If you want text to flow onto a new page or between columns, this is the
    # method to use. If, instead, you want to place bounded text outside of the
    # flow of a document (for captions, labels, charts, etc.), use {Text::Box}
    # or its convenience method {text_box}.
    #
    # Prawn attempts to wrap the text to fit within your current bounding box
    # (or `margin_box` if no bounding box is being used).  Text will flow onto
    # the next page when it reaches the bottom of the bounding box. Text wrap in
    # Prawn does not re-flow line breaks, so if you want fully automated text
    # wrapping, be sure to remove newlines before attempting to draw your
    # string.
    #
    # #### Examples
    #
    # ```ruby
    # pdf.text "Will be wrapped when it hits the edge of your bounding box"
    # pdf.text "This will be centered", align: :center
    # pdf.text "This will be right aligned", align: :right
    # pdf.text "This <i>includes <b>inline</b></i> <font size='24'>formatting</font>", inline_format: true
    # ```
    #
    # If your font contains kerning pair data that Prawn can parse, the text
    # will be kerned by default. You can disable kerning by including a `false`
    # `:kerning` option. If you want to disable kerning on an entire document,
    # set `default_kerning = false` for that document.
    #
    # #### Text Positioning Details
    #
    # The text is positioned at `font.ascender` below the baseline, making it
    # easy to use this method within bounding boxes and spans.
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
    # @option options :inline_format [Boolean]
    #   If `true`, then the string parameter is interpreted as a HTML-esque
    #   string that recognizes the following tags (assuming the default text
    #   formatter is used):
    #   - `<b></b>`{:.language-html} --- bold style.
    #   - `<i></i>`{:.language-html} --- italic style.
    #   - `<u></u>`{:.language-html} --- underline.
    #   - `<strikethrough></strikethrough>`{:.language-html} --- strikethrough.
    #   - `<sub></sub>`{:.language-html} --- subscript.
    #   - `<sup></sup>`{:.language-html} --- superscript.
    #   - `<font></font>`{:.language-html} --- with the following attributes
    #     (using double or single quotes):
    #     - `name="Helvetica"`{:.language-html} --- the font. The font name must
    #       be an AFM font with the desired faces or must be a font that is
    #       already registered using {Prawn::Document#font_families}.
    #     - `size="24"`{:.language-html} --- attribute for setting size.
    #     - `character_spacing="2.5"`{:.language-html} --- character spacing.
    #   - `<color></color>`{:.language-html} --- text color
    #     - `rgb="ffffff"`{:.language-html} or `rgb="#ffffff"`{:.language-html}
    #       --- RGB color
    #     - `c="100" m="100" y="100" k="100"`{:.language-html} --- CMYK color
    #   - `<link></link>`{:.language-html} - link, with the following
    #     attributes:
    #     - `href="http://example.com"`{:.language-html} --- an external link.
    #       Note that you must explicitly underline and color using the
    #       appropriate tags if you which to draw attention to the link.
    # @option options :kerning [Boolean] (value of document.default_kerning?)
    #   Whether or not to use kerning (if it is available with the current
    #   font).
    # @option options :size [Number] (current ofnt size) The font size to use.
    # @option options :color [Color]
    # @option options :character_spacing [Number] (0)
    #   The amount of space to add to or remove from the default character
    #   spacing.
    # @option options :style [Symbol] (current style)
    #   The style to use. The requested style must be part of the current font
    #   family.
    # @option options :indent_paragraphs [Number]
    #   The amount to indent the first line of each paragraph. Omit this option
    #   if you do not want indenting.
    # @option options :direction [:ltr, :rtl] (value of document.text_direction)
    #   Direction of the text.
    # @option options :fallback_fonts [Array<String>]
    #   An array of font names. Each name must be the name of an AFM font or the
    #   name that was used to register a family of TTF fonts (see
    #   {Prawn::Document#font_families}). If present, then each glyph will be
    #   rendered using the first font that includes the glyph, starting with the
    #   current font and then moving through `:fallback_fonts`.
    # @option option :align [:left, :center, :right, :justify]
    #   (:left if direction is :ltr, :right if direction is :rtl)
    #   Alignment within the bounding box.
    # @option options :valign [:top, :center, :bottom] (:top)
    #   Vertical alignment within the bounding box.
    # @option options :leading (Number) (value of document.default_leading)
    #   Additional space between lines.
    # @option options :final_gap [Boolean] (true)
    #   If `true`, then the space between each line is included below the last
    #   line; otherwise, {Document.y} is placed just below the descender of the
    #   last line printed.
    # @option options :mode [Symbol] (:fill)
    #   The text rendering mode to use. Use this to specify if the text should
    #   render with the fill color, stroke color or both.
    #   * `:fill` - fill text (default)
    #   * `:stroke` - stroke text
    #   * `:fill_stroke` - fill, then stroke text
    #   * `:invisible` - invisible text
    #   * `:fill_clip` - fill text then add to path for clipping
    #   * `:stroke_clip` - stroke text then add to path for clipping
    #   * `:fill_stroke_clip` - fill then stroke text, then add to path for
    #     clipping
    #   * `:clip` - add text to path for clipping
    #
    # @return [void]
    #
    # @raise [ArgumentError] if `:at` option included
    # @raise [Prawn::Errrors::CannotFit] if not wide enough to print any text
    #
    # @see PDF::Core::Text#text_rendering_mode()
    #   for a list of valid text rendering modes.
    def text(string, options = {})
      return false if string.nil?

      # we modify the options. don't change the user's hash
      options = options.dup

      p = options[:inline_format]
      if p
        p = [] unless p.is_a?(Array)
        options.delete(:inline_format)
        array = text_formatter.format(string, *p)
      else
        array = [{ text: string }]
      end

      formatted_text(array, options)
    end

    # Draws formatted text to the page.
    #
    # Formatted text is an array of hashes, where each hash defines text and
    # format information.
    #
    # @example
    #   text([{ :text => "hello" },
    #         { :text => "world",
    #           :size => 24,
    #           :styles => [:bold, :italic] }])
    #
    # @param array [Array<Hash>] array of text fragments. See
    #   {Text::Formatted#formatted_text_box} for more information on the
    #   structure of this array.
    # @param options [Hash{Symbol => any}]
    # @option options :inline_format [Boolean]
    #   If `true`, then the string parameter is interpreted as a HTML-esque
    #   string that recognizes the following tags (assuming the default text
    #   formatter is used):
    #   - `<b></b>`{:.language-html} --- bold style.
    #   - `<i></i>`{:.language-html} --- italic style.
    #   - `<u></u>`{:.language-html} --- underline.
    #   - `<strikethrough></strikethrough>`{:.language-html} --- strikethrough.
    #   - `<sub></sub>`{:.language-html} --- subscript.
    #   - `<sup></sup>`{:.language-html} --- superscript.
    #   - `<font></font>`{:.language-html} --- with the following attributes
    #     (using double or single quotes):
    #     - `name="Helvetica"`{:.language-html} --- the font. The font name must
    #       be an AFM font with the desired faces or must be a font that is
    #       already registered using {Prawn::Document#font_families}.
    #     - `size="24"`{:.language-html} --- attribute for setting size.
    #     - `character_spacing="2.5"`{:.language-html} --- character spacing.
    #   - `<color></color>`{:.language-html} --- text color
    #     - `rgb="ffffff"`{:.language-html} or `rgb="#ffffff"`{:.language-html}
    #       --- RGB color
    #     - `c="100" m="100" y="100" k="100"`{:.language-html} --- CMYK color
    #   - `<link></link>`{:.language-html} - link, with the following
    #     attributes:
    #     - `href="http://example.com"`{:.language-html} --- an external link.
    #       Note that you must explicitly underline and color using the
    #       appropriate tags if you which to draw attention to the link.
    # @option options :kerning [Boolean] (value of document.default_kerning?)
    #   Whether or not to use kerning (if it is available with the current
    #   font).
    # @option options :size [Number] (current ofnt size) The font size to use.
    # @option options :color [Color]
    # @option options :character_spacing [Number] (0)
    #   The amount of space to add to or remove from the default character
    #   spacing.
    # @option options :style [Symbol] (current style)
    #   The style to use. The requested style must be part of the current font
    #   family.
    # @option options :indent_paragraphs [Number]
    #   The amount to indent the first line of each paragraph. Omit this option
    #   if you do not want indenting.
    # @option options :direction [:ltr, :rtl] (value of document.text_direction)
    #   Direction of the text.
    # @option options :fallback_fonts [Array<String>]
    #   An array of font names. Each name must be the name of an AFM font or the
    #   name that was used to register a family of TTF fonts (see
    #   {Prawn::Document#font_families}). If present, then each glyph will be
    #   rendered using the first font that includes the glyph, starting with the
    #   current font and then moving through `:fallback_fonts`.
    # @option option :align [:left, :center, :right, :justify]
    #   (:left if direction is :ltr, :right if direction is :rtl)
    #   Alignment within the bounding box.
    # @option options :valign [:top, :center, :bottom] (:top)
    #   Vertical alignment within the bounding box.
    # @option options :leading (Number) (value of document.default_leading)
    #   Additional space between lines.
    # @option options :final_gap [Boolean] (true)
    #   If `true`, then the space between each line is included below the last
    #   line; otherwise, {Document.y} is placed just below the descender of the
    #   last line printed.
    # @option options :mode [Symbol] (:fill)
    #   The text rendering mode to use. Use this to specify if the text should
    #   render with the fill color, stroke color or both.
    #   * `:fill` - fill text (default)
    #   * `:stroke` - stroke text
    #   * `:fill_stroke` - fill, then stroke text
    #   * `:invisible` - invisible text
    #   * `:fill_clip` - fill text then add to path for clipping
    #   * `:stroke_clip` - stroke text then add to path for clipping
    #   * `:fill_stroke_clip` - fill then stroke text, then add to path for
    #     clipping
    #   * `:clip` - add text to path for clipping
    #
    # @return [void]
    #
    # @raise [ArgumentError] if `:at` option included
    # @raise [Prawn::Errrors::CannotFit] if not wide enough to print any text
    #
    # @see PDF::Core::Text#text_rendering_mode()
    #   for a list of valid text rendering modes.
    def formatted_text(array, options = {})
      options = inspect_options_for_text(options.dup)

      color = options.delete(:color)
      if color
        array =
          array.map { |fragment|
            fragment[:color] ? fragment : fragment.merge(color: color)
          }
      end

      if @indent_paragraphs
        text_formatter.array_paragraphs(array).each do |paragraph|
          remaining_text = draw_indented_formatted_line(paragraph, options)

          if @no_text_printed && !@all_text_printed
            @bounding_box.move_past_bottom
            remaining_text = draw_indented_formatted_line(paragraph, options)
          end

          unless @all_text_printed
            remaining_text = fill_formatted_text_box(remaining_text, options)
            draw_remaining_formatted_text_on_new_pages(remaining_text, options)
          end
        end
      else
        remaining_text = fill_formatted_text_box(array, options)
        draw_remaining_formatted_text_on_new_pages(remaining_text, options)
      end
    end

    # Draws text on the page, beginning at the point specified by the `:at`
    # option the string is assumed to be pre-formatted to properly fit the page.
    #
    # ```ruby
    # pdf.draw_text "Hello World", at: [100, 100]
    # pdf.draw_text "Goodbye World", at: [50,50], size: 16
    # ```
    #
    # If your font contains kerning pair data that Prawn can parse, the
    # text will be kerned by default. You can disable kerning by including
    # a `false` `:kerning` option. If you want to disable kerning on an
    # entire document, set `default_kerning = false` for that document
    #
    # #### Text Positioning Details
    #
    # Prawn will position your text by the left-most edge of its baseline, and
    # flow along a single line. (This means that `:align` will not work)
    #
    # #### Rotation
    #
    # Text can be rotated before it is placed on the canvas by specifying the
    # `:rotate` option with a given angle. Rotation occurs counter-clockwise.
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
    # @param text [String]
    # @param options [Hash{Symbol => any}]
    # @option options :at [Array(Number, Number)] **Required**.
    #   The position at which to start the text.
    # @option options :kerning [Boolean] (value of default_kerning?)
    #   Whether or not to use kerning (if it is available with the current
    #   font).
    # @option options :size [Number] (current font size)
    #   The font size to use.
    # @option options :style [Symbol] (current style)
    #   The style to use. The requested style must be part of the current font
    #   family.
    # @option options :rotate [Number] The angle to which to rotate text.
    # @return [void]
    # @raise [ArgumentError]
    #   If `:at` option is omitted or `:align</tt> option is included.
    def draw_text(text, options)
      options = inspect_options_for_draw_text(options.dup)

      # dup because normalize_encoding changes the string
      text = text.to_s.dup
      save_font do
        process_text_options(options)
        text = font.normalize_encoding(text)
        font_size(options[:size]) { draw_text!(text, options) }
      end
    end

    # Low level text placement method.
    #
    # All font and size alterations should already be set.
    #
    # @param text [String]
    # @param options [Hash{Symbol => any}]
    # @option options :at [Array(Number, Number)]
    #   The position at which to start the text.
    # @option options :kerning [Boolean]
    #   Whether or not to use kerning (if it is available with the current
    #   font).
    # @option options :size [Number]
    #   The font size to use.
    # @option options :style [Symbol]
    #   The style to use. The requested style must be part of the current font
    #   family.
    # @option options :rotate [Number] The angle to which to rotate text.
    # @return [void]
    def draw_text!(text, options)
      unless font.unicode? || font.class.hide_m17n_warning || text.ascii_only?
        warn(
          "PDF's built-in fonts have very limited support for " \
            "internationalized text.\nIf you need full UTF-8 support, " \
            "consider using an external font instead.\n\nTo disable this " \
            "warning, add the following line to your code:\n" \
            "Prawn::Fonts::AFM.hide_m17n_warning = true\n",
        )

        font.class.hide_m17n_warning = true
      end

      x, y = map_to_absolute(options[:at])
      add_text_content(text, x, y, options)
    end

    # Gets height of text in PDF points.
    #
    # @note This method takes the same options as {#text}, _except_
    #   `:indent_paragraphs`.
    #
    # @example
    #   text_height = height_of("hello\nworld")
    #
    # @param string [String]
    # @param options [Hash{Symbol => any}]
    # @option options :inline_format [Boolean]
    #   If `true`, then the string parameter is interpreted as a HTML-esque
    #   string that recognizes the following tags (assuming the default text
    #   formatter is used):
    #   - `<b></b>`{:.language-html} --- bold style.
    #   - `<i></i>`{:.language-html} --- italic style.
    #   - `<u></u>`{:.language-html} --- underline.
    #   - `<strikethrough></strikethrough>`{:.language-html} --- strikethrough.
    #   - `<sub></sub>`{:.language-html} --- subscript.
    #   - `<sup></sup>`{:.language-html} --- superscript.
    #   - `<font></font>`{:.language-html} --- with the following attributes
    #     (using double or single quotes):
    #     - `name="Helvetica"`{:.language-html} --- the font. The font name must
    #       be an AFM font with the desired faces or must be a font that is
    #       already registered using {Prawn::Document#font_families}.
    #     - `size="24"`{:.language-html} --- attribute for setting size.
    #     - `character_spacing="2.5"`{:.language-html} --- character spacing.
    #   - `<color></color>`{:.language-html} --- text color
    #     - `rgb="ffffff"`{:.language-html} or `rgb="#ffffff"`{:.language-html}
    #       --- RGB color
    #     - `c="100" m="100" y="100" k="100"`{:.language-html} --- CMYK color
    #   - `<link></link>`{:.language-html} - link, with the following
    #     attributes:
    #     - `href="http://example.com"`{:.language-html} --- an external link.
    #       Note that you must explicitly underline and color using the
    #       appropriate tags if you which to draw attention to the link.
    # @option options :kerning [Boolean] (value of document.default_kerning?)
    #   Whether or not to use kerning (if it is available with the current
    #   font).
    # @option options :size [Number] (current ofnt size) The font size to use.
    # @option options :color [Color]
    # @option options :character_spacing [Number] (0)
    #   The amount of space to add to or remove from the default character
    #   spacing.
    # @option options :style [Symbol] (current style)
    #   The style to use. The requested style must be part of the current font
    #   family.
    # @option options :direction [:ltr, :rtl] (value of document.text_direction)
    #   Direction of the text.
    # @option options :fallback_fonts [Array<String>]
    #   An array of font names. Each name must be the name of an AFM font or the
    #   name that was used to register a family of TTF fonts (see
    #   {Prawn::Document#font_families}). If present, then each glyph will be
    #   rendered using the first font that includes the glyph, starting with the
    #   current font and then moving through `:fallback_fonts`.
    # @option option :align [:left, :center, :right, :justify]
    #   (:left if direction is :ltr, :right if direction is :rtl)
    #   Alignment within the bounding box.
    # @option options :valign [:top, :center, :bottom] (:top)
    #   Vertical alignment within the bounding box.
    # @option options :leading (Number) (value of document.default_leading)
    #   Additional space between lines.
    # @option options :final_gap [Boolean] (true)
    #   If `true`, then the space between each line is included below the last
    #   line; otherwise, {Document.y} is placed just below the descender of the
    #   last line printed.
    # @option options :mode [Symbol] (:fill)
    #   The text rendering mode to use. Use this to specify if the text should
    #   render with the fill color, stroke color or both.
    #   * `:fill` - fill text (default)
    #   * `:stroke` - stroke text
    #   * `:fill_stroke` - fill, then stroke text
    #   * `:invisible` - invisible text
    #   * `:fill_clip` - fill text then add to path for clipping
    #   * `:stroke_clip` - stroke text then add to path for clipping
    #   * `:fill_stroke_clip` - fill then stroke text, then add to path for
    #     clipping
    #   * `:clip` - add text to path for clipping
    #
    # @return [void]
    #
    # @raise [ArgumentError] if `:at` option included
    # @raise [Prawn::Errrors::CannotFit] if not wide enough to print any text
    # @raise [NotImplementedError] if `:indent_paragraphs` option included.
    #
    # @see PDF::Core::Text#text_rendering_mode()
    #   for a list of valid text rendering modes.
    # @see height_of_formatted
    def height_of(string, options = {})
      height_of_formatted([{ text: string }], options)
    end

    # Gets height of formatted text in PDF points.
    #
    # @note This method takes the same options as {#text}, _except_
    #   `:indent_paragraphs`.
    #
    # @example
    #   height_of_formatted([{ :text => "hello" },
    #                        { :text => "world",
    #                          :size => 24,
    #                          :styles => [:bold, :italic] }])
    #
    # @param array [Array<Hash>] text fragments.
    # @param options [Hash{Symbol => any}]
    # @option options :inline_format [Boolean]
    #   If `true`, then the string parameter is interpreted as a HTML-esque
    #   string that recognizes the following tags (assuming the default text
    #   formatter is used):
    #   - `<b></b>`{:.language-html} --- bold style.
    #   - `<i></i>`{:.language-html} --- italic style.
    #   - `<u></u>`{:.language-html} --- underline.
    #   - `<strikethrough></strikethrough>`{:.language-html} --- strikethrough.
    #   - `<sub></sub>`{:.language-html} --- subscript.
    #   - `<sup></sup>`{:.language-html} --- superscript.
    #   - `<font></font>`{:.language-html} --- with the following attributes
    #     (using double or single quotes):
    #     - `name="Helvetica"`{:.language-html} --- the font. The font name must
    #       be an AFM font with the desired faces or must be a font that is
    #       already registered using {Prawn::Document#font_families}.
    #     - `size="24"`{:.language-html} --- attribute for setting size.
    #     - `character_spacing="2.5"`{:.language-html} --- character spacing.
    #   - `<color></color>`{:.language-html} --- text color
    #     - `rgb="ffffff"`{:.language-html} or `rgb="#ffffff"`{:.language-html}
    #       --- RGB color
    #     - `c="100" m="100" y="100" k="100"`{:.language-html} --- CMYK color
    #   - `<link></link>`{:.language-html} - link, with the following
    #     attributes:
    #     - `href="http://example.com"`{:.language-html} --- an external link.
    #       Note that you must explicitly underline and color using the
    #       appropriate tags if you which to draw attention to the link.
    # @option options :kerning [Boolean] (value of document.default_kerning?)
    #   Whether or not to use kerning (if it is available with the current
    #   font).
    # @option options :size [Number] (current ofnt size) The font size to use.
    # @option options :color [Color]
    # @option options :character_spacing [Number] (0)
    #   The amount of space to add to or remove from the default character
    #   spacing.
    # @option options :style [Symbol] (current style)
    #   The style to use. The requested style must be part of the current font
    #   family.
    # @option options :direction [:ltr, :rtl] (value of document.text_direction)
    #   Direction of the text.
    # @option options :fallback_fonts [Array<String>]
    #   An array of font names. Each name must be the name of an AFM font or the
    #   name that was used to register a family of TTF fonts (see
    #   {Prawn::Document#font_families}). If present, then each glyph will be
    #   rendered using the first font that includes the glyph, starting with the
    #   current font and then moving through `:fallback_fonts`.
    # @option option :align [:left, :center, :right, :justify]
    #   (:left if direction is :ltr, :right if direction is :rtl)
    #   Alignment within the bounding box.
    # @option options :valign [:top, :center, :bottom] (:top)
    #   Vertical alignment within the bounding box.
    # @option options :leading (Number) (value of document.default_leading)
    #   Additional space between lines.
    # @option options :final_gap [Boolean] (true)
    #   If `true`, then the space between each line is included below the last
    #   line; otherwise, {Document.y} is placed just below the descender of the
    #   last line printed.
    # @option options :mode [Symbol] (:fill)
    #   The text rendering mode to use. Use this to specify if the text should
    #   render with the fill color, stroke color or both.
    #   * `:fill` - fill text (default)
    #   * `:stroke` - stroke text
    #   * `:fill_stroke` - fill, then stroke text
    #   * `:invisible` - invisible text
    #   * `:fill_clip` - fill text then add to path for clipping
    #   * `:stroke_clip` - stroke text then add to path for clipping
    #   * `:fill_stroke_clip` - fill then stroke text, then add to path for
    #     clipping
    #   * `:clip` - add text to path for clipping
    #
    # @return [void]
    #
    # @raise [ArgumentError] if `:at` option included
    # @raise [Prawn::Errrors::CannotFit] if not wide enough to print any text
    # @raise [NotImplementedError] if `:indent_paragraphs` option included.
    #
    # @see PDF::Core::Text#text_rendering_mode()
    #   for a list of valid text rendering modes.
    # @see height_of
    def height_of_formatted(array, options = {})
      if options[:indent_paragraphs]
        raise NotImplementedError,
          ':indent_paragraphs option not available with height_of'
      end
      process_final_gap_option(options)
      box = Text::Formatted::Box.new(
        array,
        options.merge(height: 100_000_000, document: self),
      )
      box.render(dry_run: true)

      height = box.height
      height += box.line_gap + box.leading if @final_gap
      height
    end

    private

    def draw_remaining_formatted_text_on_new_pages(remaining_text, options)
      until remaining_text.empty?
        @bounding_box.move_past_bottom
        previous_remaining_text = remaining_text
        remaining_text = fill_formatted_text_box(remaining_text, options)
        break if remaining_text == previous_remaining_text
      end
    end

    def draw_indented_formatted_line(string, options)
      gap =
        if options.fetch(:direction, text_direction) == :ltr
          [@indent_paragraphs, 0]
        else
          [0, @indent_paragraphs]
        end

      indent(*gap) do
        fill_formatted_text_box(string, options.dup.merge(single_line: true))
      end
    end

    def fill_formatted_text_box(text, options)
      merge_text_box_positioning_options(options)
      box = Text::Formatted::Box.new(text, options)
      remaining_text = box.render
      @no_text_printed = box.nothing_printed?
      @all_text_printed = box.everything_printed?

      self.y -= box.height

      # If there's no remaining_text we don't really want to treat this line
      # in a special way, we printed everything we wanted so the special
      # single_line logic should not be triggered here.
      if @final_gap || (options[:single_line] && !@all_text_printed)
        self.y -= box.line_gap + box.leading
      end

      remaining_text
    end

    def merge_text_box_positioning_options(options)
      bottom =
        if @bounding_box.stretchy?
          @margin_box.absolute_bottom
        else
          @bounding_box.absolute_bottom
        end

      options[:height] = y - bottom
      options[:width] = bounds.width
      options[:at] = [
        @bounding_box.left_side - @bounding_box.absolute_left,
        y - @bounding_box.absolute_bottom,
      ]
    end

    def inspect_options_for_draw_text(options)
      if options[:at].nil?
        raise ArgumentError, 'The :at option is required for draw_text'
      elsif options[:align]
        raise ArgumentError, 'The :align option does not work with draw_text'
      end

      if options[:kerning].nil?
        options[:kerning] = default_kerning?
      end
      valid_options = PDF::Core::Text::VALID_OPTIONS + %i[at rotate]
      Prawn.verify_options(valid_options, options)
      options
    end

    def inspect_options_for_text(options)
      if options[:at]
        raise ArgumentError,
          ':at is no longer a valid option with text.' \
            'use draw_text or text_box instead'
      end
      process_final_gap_option(options)
      process_indent_paragraphs_option(options)
      options[:document] = self
      options
    end

    def process_final_gap_option(options)
      @final_gap = options[:final_gap].nil? || options[:final_gap]
      options.delete(:final_gap)
    end

    def process_indent_paragraphs_option(options)
      @indent_paragraphs = options[:indent_paragraphs]
      options.delete(:indent_paragraphs)
    end

    def move_text_position(amount)
      bottom =
        if @bounding_box.stretchy?
          @margin_box.absolute_bottom
        else
          @bounding_box.absolute_bottom
        end

      @bounding_box.move_past_bottom if (y - amount) < bottom

      self.y -= amount
    end
  end
end
