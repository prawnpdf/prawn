# frozen_string_literal: true

# text/formatted/rectangle.rb : Implements text boxes with formatted text
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Text
    module Formatted
      # Formatted text box.
      #
      # Generally, one would use the {Prawn::Text::Formatted#formatted_text_box}
      # convenience method. However, using `Text::Formatted::Box.new` in
      # conjunction with `#render(dry_run: true)` enables one to do calculations
      # prior to placing text on the page, or to determine how much vertical
      # space was consumed by the printed text
      class Box
        include Prawn::Text::Formatted::Wrap

        # @group Experimental API

        # The text that was successfully printed (or, if `:dry_run` was
        # used, the text that would have been successfully printed).
        # @return [Array<Hash>]
        attr_reader :text

        # True if nothing printed (or, if `:dry_run` was used, nothing would
        # have been successfully printed).
        #
        # @return [Boolean]
        def nothing_printed?
          @nothing_printed
        end

        # True if everything printed (or, if `:dry_run` was used, everything
        # would have been successfully printed).
        #
        # @return [Boolean]
        def everything_printed?
          @everything_printed
        end

        # The upper left corner of the text box.
        # @return [Array(Number, Number)]
        attr_reader :at

        # The line height of the last line printed.
        # @return [Number]
        attr_reader :line_height

        # The height of the ascender of the last line printed.
        # @return [Number]
        attr_reader :ascender

        # The height of the descender of the last line printed.
        # @return [Number]
        attr_reader :descender

        # The leading used during printing.
        # @return [Number]
        attr_reader :leading

        # Gap between adjacent lines of text.
        #
        # @return [Number]
        def line_gap
          line_height - (ascender + descender)
        end

        # See Prawn::Text#text_box for valid options
        #
        # @param formatted_text [Array<Hash{Symbol => any}>]
        #   Formatted text is an array of hashes, where each hash defines text
        #   and format information. The following hash options are supported:
        #
        #   - `:text` --- the text to format according to the other hash
        #     options.
        #   - `:styles` --- an array of styles to apply to this text. Available
        #     styles include `:bold`, `:italic`, `:underline`, `:strikethrough`,
        #     `:subscript`, and `:superscript`.
        #   - `:size` ---a number denoting the font size to apply to this text.
        #   - `:character_spacing` --- a number denoting how much to increase or
        #     decrease the default spacing between characters.
        #   - `:font` --- the name of a font. The name must be an AFM font with
        #     the desired faces or must be a font that is already registered
        #     using {Prawn::Document#font_families}.
        #   - `:color` --- anything compatible with
        #     {Prawn::Graphics::Color#fill_color} and
        #     {Prawn::Graphics::Color#stroke_color}.
        #   - :link` --- a URL to which to create a link. A clickable link will
        #     be created to that URL. Note that you must explicitly underline
        #     and color using the appropriate tags if you which to draw
        #     attention to the link.
        #   - `:anchor` --- a destination that has already been or will be
        #     registered using `PDF::Core::Destinations#add_dest`. A clickable
        #     link will be created to that destination. Note that you must
        #     explicitly underline and color using the appropriate tags if you
        #     which to draw attention to the link.
        #   - `:local` --- a file or application to be opened locally.
        #     A clickable link will be created to the provided local file or
        #     application. If the file is another PDF, it will be opened in
        #     a new window. Note that you must explicitly underline and color
        #     using the appropriate options if you which to draw attention to
        #     the link.
        #   - `:draw_text_callback` --- if provided, this Proc will be called
        #     instead of {Prawn::Document#draw_text!} once per fragment for
        #     every low-level addition of text to the page.
        #   - `:callback` --- an object (or array of such objects) with two
        #     methods: `render_behind` and `render_in_front`, which are called
        #     immediately prior to and immediately after rendering the text
        #     fragment and which are passed the fragment as an argument.
        # @param options [Hash{Symbol => any}]
        # @option options :document [Prawn::Document] Owning document.
        # @option options :kerning [Boolean]
        #   (value of document.default_kerning?)
        #   Whether or not to use kerning (if it is available with the current
        #   font).
        # @option options :size [Number] (current font size)
        #   The font size to use.
        # @option options :character_spacing [Number] (0)
        #   The amount of space to add to or remove from the default character
        #   spacing.
        # @option options :disable_wrap_by_char [Boolean] (false)
        #   Whether or not to prevent mid-word breaks when text does not fit in
        #   box.
        # @option options :mode [Symbol] (:fill)
        #   The text rendering mode. See documentation for
        #   {Prawn::Document#text_rendering_mode} for a list of valid options.
        # @option option :style [Symbol] (current style)
        #   The style to use. The requested style must be part of the current
        #   font family.
        # @option option :at [Array(Number, Number)] (bounds top left corner)
        #   The upper left corner of the box.
        # @option options :width [Number] (bounds.right - at[0])
        #   The width of the box.
        # @option options :height [Number] (default_height())
        #   The height of the box.
        # @option options :direction [:ltr, :rtl]
        #   (value of document.text_direction)
        #   Direction of the text (left-to-right or right-to-left).
        # @option options :fallback_fonts [Array<String>]
        #   An array of font names. Each name must be the name of an AFM font or
        #   the name that was used to register a family of external fonts (see
        #   {Prawn::Document#font_families}). If present, then each glyph will
        #   be rendered using the first font that includes the glyph, starting
        #   with the current font and then moving through `:fallback_fonts`.
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
        # @option options :overflow [:truncate, :shrink_to_fit, :expand]
        #   (:truncate)
        #   This controls the behavior when the amount of text exceeds the
        #   available space.
        # @option options :min_font_size [Number] (5)
        #   The minimum font size to use when `:overflow` is set to
        #   `:shrink_to_fit` (that is the font size will not be reduced to less
        #   than this value, even if it means that some text will be cut off).
        def initialize(formatted_text, options = {})
          @inked = false
          Prawn.verify_options(valid_options, options)
          options = options.dup

          self.class.extensions.reverse_each { |e| extend(e) }

          @overflow = options[:overflow] || :truncate
          @disable_wrap_by_char = options[:disable_wrap_by_char]

          self.original_text = formatted_text
          @text = nil

          @document = options[:document]
          @direction = options[:direction] || @document.text_direction
          @fallback_fonts = options[:fallback_fonts] ||
            @document.fallback_fonts
          @at = (
            options[:at] || [@document.bounds.left, @document.bounds.top]
          ).dup
          @width = options[:width] ||
            (@document.bounds.right - @at[0])
          @height = options[:height] || default_height
          @align = options[:align] ||
            (@direction == :rtl ? :right : :left)
          @vertical_align = options[:valign] || :top
          @leading = options[:leading] || @document.default_leading
          @character_spacing = options[:character_spacing] ||
            @document.character_spacing
          @mode = options[:mode] || @document.text_rendering_mode
          @rotate = options[:rotate] || 0
          @rotate_around = options[:rotate_around] || :upper_left
          @single_line = options[:single_line]
          @draw_text_callback = options[:draw_text_callback]

          # if the text rendering mode is :unknown, force it back to :fill
          if @mode == :unknown
            @mode = :fill
          end

          if @overflow == :expand
            # if set to expand, then we simply set the bottom
            # as the bottom of the document bounds, since that
            # is the maximum we should expand to
            @height = default_height
            @overflow = :truncate
          end
          @min_font_size = options[:min_font_size] || 5
          if options[:kerning].nil?
            options[:kerning] = @document.default_kerning?
          end
          @options = {
            kerning: options[:kerning],
            size: options[:size],
            style: options[:style],
          }

          super(formatted_text, options)
        end

        # Render text to the document based on the settings defined in
        # constructor.
        #
        # In order to facilitate look-ahead calculations, this method accepts
        # a `dry_run: true` option. If provided, then everything is executed as
        # if rendering, with the exception that nothing is drawn on the page.
        # Useful for look-ahead computations of height, unprinted text, etc.
        #
        # @param flags [Hash{Symbol => any}]
        # @option flags :dry_run [Boolean] (false)
        #   Do not draw the text. Everything else is done.
        # @return [Array<Hash>]
        #   A formatted text array representing any text that did not print
        #   under the current settings.
        # @raise [Prawn::Text::Formatted::Arranger::BadFontFamily]
        #   If no font family is defined for the current font.
        # @raise [Prawn::Errors::CannotFit]
        #   If not wide enough to print any text.
        def render(flags = {})
          unprinted_text = []

          @document.save_font do
            @document.character_spacing(@character_spacing) do
              @document.text_rendering_mode(@mode) do
                process_options

                text = normalized_text(flags)

                @document.font_size(@font_size) do
                  shrink_to_fit(text) if @overflow == :shrink_to_fit
                  process_vertical_alignment(text)
                  @inked = true unless flags[:dry_run]
                  unprinted_text =
                    if @rotate != 0 && @inked
                      render_rotated(text)
                    else
                      wrap(text)
                    end
                  @inked = false
                end
              end
            end
          end

          unprinted_text.map do |e|
            e.merge(text: @document.font.to_utf8(e[:text]))
          end
        end

        # The width available at this point in the box.
        #
        # @return [Number]
        def available_width
          @width
        end

        # The height actually used during the previous {render}.
        #
        # @return [Number]
        def height
          return 0 if @baseline_y.nil? || @descender.nil?

          (@baseline_y - @descender).abs
        end

        # @private
        # @param fragment [Prawn::Text::Formatted::Fragment]
        # @param accumulated_width [Number]
        # @param line_width [Number]
        # @param word_spacing [Number]
        # @return [void]
        def draw_fragment(
          fragment, accumulated_width = 0, line_width = 0, word_spacing = 0
        )
          case @align
          when :left
            x = @at[0]
          when :center
            x = @at[0] + (@width * 0.5) - (line_width * 0.5)
          when :right
            x = @at[0] + @width - line_width
          when :justify
            x =
              if @direction == :ltr
                @at[0]
              else
                @at[0] + @width - line_width
              end
          else
            raise ArgumentError,
              'align must be one of :left, :right, :center or :justify symbols'
          end

          x += accumulated_width

          y = @at[1] + @baseline_y

          y += fragment.y_offset

          fragment.left = x
          fragment.baseline = y

          if @inked
            draw_fragment_underlays(fragment)

            @document.word_spacing(word_spacing) do
              if @draw_text_callback
                @draw_text_callback.call(
                  fragment.text,
                  at: [x, y],
                  kerning: @kerning,
                )
              else
                @document.draw_text!(
                  fragment.text,
                  at: [x, y],
                  kerning: @kerning,
                )
              end
            end

            draw_fragment_overlays(fragment)
          end
        end

        # @group Extension API

        # Text box extensions.
        #
        # Example:
        #
        # ```ruby
        # module MyWrap
        #   def wrap(array)
        #     initialize_wrap([{ text: 'all your base are belong to us' }])
        #     @line_wrap.wrap_line(
        #       document: @document,
        #       kerning: @kerning,
        #       width: 10000,
        #       arranger: @arranger
        #     )
        #     fragment = @arranger.retrieve_fragment
        #     format_and_draw_fragment(fragment, 0, @line_wrap.width, 0)
        #     []
        #   end
        # end
        #
        # Prawn::Text::Formatted::Box.extensions << MyWrap
        #
        # box = Prawn::Text::Formatted::Box.new('hello world')
        # box.render("why can't I print anything other than" +
        #            '"all your base are belong to us"?')
        # ```
        #
        # See {Prawn::Text::Formatted::Wrap} for what is required of the
        # wrap method if you want to override the default wrapping algorithm.
        #
        # @return [Array<Module>]
        def self.extensions
          @extensions ||= []
        end

        # @private
        def self.inherited(base)
          super
          extensions.each { |e| base.extensions << e }
        end

        # @private
        def valid_options
          PDF::Core::Text::VALID_OPTIONS + %i[
            at
            height width
            align valign
            rotate rotate_around
            overflow min_font_size
            disable_wrap_by_char
            leading character_spacing
            mode single_line
            document
            direction
            fallback_fonts
            draw_text_callback
          ]
        end

        private

        def normalized_text(flags)
          text = normalize_encoding

          text.each { |t| t.delete(:color) } if flags[:dry_run]

          text
        end

        def original_text
          @original_array.map(&:dup)
        end

        def original_text=(formatted_text)
          @original_array = formatted_text
        end

        def normalize_encoding
          formatted_text = original_text

          unless @fallback_fonts.empty?
            formatted_text = process_fallback_fonts(formatted_text)
          end

          formatted_text.each do |hash|
            if hash[:font]
              @document.font(hash[:font]) do
                hash[:text] = @document.font.normalize_encoding(hash[:text])
              end
            else
              hash[:text] = @document.font.normalize_encoding(hash[:text])
            end
          end

          formatted_text
        end

        def process_fallback_fonts(formatted_text)
          modified_formatted_text = []

          formatted_text.each do |hash|
            fragments = analyze_glyphs_for_fallback_font_support(hash)
            modified_formatted_text.concat(fragments)
          end

          modified_formatted_text
        end

        def analyze_glyphs_for_fallback_font_support(hash)
          font_glyph_pairs = []

          original_font = @document.font.family
          fragment_font = hash[:font] || original_font
          fragment_font_options =
            (fragment_font_style = font_style(hash[:styles])) == :normal ? {} : { style: fragment_font_style }

          fallback_fonts = @fallback_fonts.dup
          # always default back to the current font if the glyph is missing from
          # all fonts
          fallback_fonts << fragment_font

          @document.save_font do
            hash[:text].each_char do |char|
              font_glyph_pairs << [
                find_font_for_this_glyph(
                  char,
                  fragment_font,
                  fallback_fonts.dup,
                  fragment_font_options,
                ),
                char,
              ]
            end
          end

          # Don't add a :font to fragments if it wasn't there originally
          if hash[:font].nil?
            font_glyph_pairs.each do |pair|
              pair[0] = nil if pair[0] == original_font
            end
          end

          form_fragments_from_like_font_glyph_pairs(font_glyph_pairs, hash)
        end

        def font_style(styles)
          if styles
            if styles.include?(:bold)
              styles.include?(:italic) ? :bold_italic : :bold
            elsif styles.include?(:italic)
              :italic
            else
              :normal
            end
          else
            :normal
          end
        end

        def find_font_for_this_glyph(char, current_font, fallback_fonts, current_font_options = {})
          @document.font(current_font, current_font_options)
          if fallback_fonts.empty? || @document.font.glyph_present?(char)
            current_font
          else
            find_font_for_this_glyph(char, fallback_fonts.shift, fallback_fonts, current_font_options)
          end
        end

        def form_fragments_from_like_font_glyph_pairs(font_glyph_pairs, hash)
          fragments = []
          fragment = nil
          current_font = nil

          font_glyph_pairs.each do |font, char|
            if font != current_font || fragments.count.zero?
              current_font = font
              fragment = hash.dup
              fragment[:text] = char
              fragment[:font] = font unless font.nil?
              fragments << fragment
            else
              fragment[:text] += char
            end
          end

          fragments
        end

        def move_baseline_down
          if @baseline_y.zero?
            @baseline_y = -@ascender
          else
            @baseline_y -= (@line_height + @leading)
          end
        end

        # Returns the default height to be used if none is provided or if the
        # overflow option is set to :expand. If we are in a stretchy bounding
        # box, assume we can stretch to the bottom of the innermost non-stretchy
        # box.
        #
        def default_height
          # Find the "frame", the innermost non-stretchy bbox.
          frame = @document.bounds
          frame = frame.parent while frame.stretchy? && frame.parent

          @at[1] + @document.bounds.absolute_bottom - frame.absolute_bottom
        end

        def process_vertical_alignment(text)
          # The vertical alignment must only be done once per text box, but
          # we need to wait until render() is called so that the fonts are set
          # up properly for wrapping. So guard with a boolean to ensure this is
          # only run once.
          if defined?(@vertical_alignment_processed) &&
              @vertical_alignment_processed
            return
          end

          @vertical_alignment_processed = true

          return if @vertical_align == :top

          wrap(text)

          case @vertical_align
          when :center
            @at[1] -= (@height - height + @descender) * 0.5
          when :bottom
            @at[1] -= (@height - height)
          else
            raise ArgumentError,
              'valign must be one of :left, :right or :center symbols'
          end

          @height = height
        end

        # Decrease the font size until the text fits or the min font
        # size is reached
        def shrink_to_fit(text)
          loop do
            if @disable_wrap_by_char && @font_size > @min_font_size
              begin
                wrap(text)
              rescue Errors::CannotFit
                # Ignore errors while we can still attempt smaller
                # font sizes.
              end
            else
              wrap(text)
            end

            break if @everything_printed || @font_size <= @min_font_size

            @font_size = [@font_size - 0.5, @min_font_size].max
            @document.font_size = @font_size
          end
        end

        def process_options
          # must be performed within a save_font block because
          # document.process_text_options sets the font
          @document.process_text_options(@options)
          @font_size = @options[:size]
          @kerning = @options[:kerning]
        end

        def render_rotated(text)
          unprinted_text = ''

          case @rotate_around
          when :center
            x = @at[0] + (@width * 0.5)
            y = @at[1] - (@height * 0.5)
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

          @document.rotate(@rotate, origin: [x, y]) do
            unprinted_text = wrap(text)
          end
          unprinted_text
        end

        def draw_fragment_underlays(fragment)
          fragment.callback_objects.each do |obj|
            obj.render_behind(fragment) if obj.respond_to?(:render_behind)
          end
        end

        def draw_fragment_overlays(fragment)
          draw_fragment_overlay_styles(fragment)
          draw_fragment_overlay_link(fragment)
          draw_fragment_overlay_anchor(fragment)
          draw_fragment_overlay_local(fragment)
          fragment.callback_objects.each do |obj|
            obj.render_in_front(fragment) if obj.respond_to?(:render_in_front)
          end
        end

        def draw_fragment_overlay_link(fragment)
          return unless fragment.link

          box = fragment.absolute_bounding_box
          @document.link_annotation(
            box,
            Border: [0, 0, 0],
            A: {
              Type: :Action,
              S: :URI,
              URI: PDF::Core::LiteralString.new(fragment.link),
            },
          )
        end

        def draw_fragment_overlay_anchor(fragment)
          return unless fragment.anchor

          box = fragment.absolute_bounding_box
          @document.link_annotation(
            box,
            Border: [0, 0, 0],
            Dest: fragment.anchor,
          )
        end

        def draw_fragment_overlay_local(fragment)
          return unless fragment.local

          box = fragment.absolute_bounding_box
          @document.link_annotation(
            box,
            Border: [0, 0, 0],
            A: {
              Type: :Action,
              S: :Launch,
              F: PDF::Core::LiteralString.new(fragment.local),
              NewWindow: true,
            },
          )
        end

        def draw_fragment_overlay_styles(fragment)
          if fragment.styles.include?(:underline)
            @document.stroke_line(fragment.underline_points)
          end

          if fragment.styles.include?(:strikethrough)
            @document.stroke_line(fragment.strikethrough_points)
          end
        end
      end
    end
  end
end
