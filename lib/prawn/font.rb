# frozen_string_literal: true

require_relative 'font_metric_cache'

module Prawn
  class Document # rubocop: disable Style/Documentation
    # @group Stable API

    # Default empty options.
    DEFAULT_OPTS = {}.freeze

    # Without arguments, this returns the currently selected font. Otherwise, it
    # sets the current font. When a block is used, the font is applied
    # transactionally and is rolled back when the block exits.
    #
    # ```ruby
    # Prawn::Document.generate("font.pdf") do
    #   text "Default font is Helvetica"
    #
    #   font "Times-Roman"
    #   text "Now using Times-Roman"
    #
    #   font("DejaVuSans.ttf") do
    #     text "Using TTF font from file DejaVuSans.ttf"
    #     font "Courier", style: :bold
    #     text "You see this in bold Courier"
    #   end
    #
    #   text "Times-Roman, again"
    # end
    # ```
    #
    # The `name` parameter must be a string. It can be one of the 14 built-in
    # fonts supported by PDF, or the location of a TTF file. The
    # {Fonts::AFM::BUILT_INS} array specifies the valid built in font names.
    #
    # If a TTF/OTF font is specified, the glyphs necessary to render your
    # document will be embedded in the rendered PDF. This should be your
    # preferred option in most cases. It will increase the size of the resulting
    # file, but also make it more portable.
    #
    # The options parameter is an optional hash providing size and style. To use
    # the :style option you need to map those font styles to their respective
    # font files.
    #
    # @param name [String] font name. It can be:
    #   - One of 14 PDF built-in fonts.
    #   - A font file path.
    #   - A font name defined in {font_families}
    # @param options [Hash{Symbol => any}]
    # @option options :style [Symbol] font style
    # @yield
    # @return [Font]
    # @see #font_families
    # @see Font::AFM::BUILT_INS
    def font(name = nil, options = DEFAULT_OPTS)
      return((defined?(@font) && @font) || font('Helvetica')) if name.nil?

      if state.pages.empty? && !state.page.in_stamp_stream?
        raise Prawn::Errors::NotOnPage
      end

      new_font = find_font(name.to_s, options)

      if block_given?
        save_font do
          set_font(new_font, options[:size])
          yield
        end
      else
        set_font(new_font, options[:size])
      end

      @font
    end

    # When called with no argument, returns the current font size.
    #
    # When called with a single argument but no block, sets the current font
    # size. When a block is used, the font size is applied transactionally and
    # is rolled back when the block exits. You may still change the font size
    # within a transactional block for individual text segments, or nested calls
    # to `font_size`.
    #
    # @example
    #   Prawn::Document.generate("font_size.pdf") do
    #     font_size 16
    #     text "At size 16"
    #
    #     font_size(10) do
    #       text "At size 10"
    #       text "At size 6", size: 6
    #       text "At size 10"
    #     end
    #
    #     text "At size 16"
    #   end
    #
    # @overload font_size()
    #   @return [Number] vurrent font size
    # @overload font_size(points)
    #   @param points [Number] new font size
    #   @yield if block is provided font size is set only for the duration of
    #    the block
    #   @return [void]
    def font_size(points = nil)
      return @font_size unless points

      size_before_yield = @font_size
      @font_size = points
      block_given? ? yield : return
      @font_size = size_before_yield
    end

    # Sets the font size.
    #
    # @param size [Number]
    # @return [Number]
    def font_size=(size)
      font_size(size)
    end

    # Returns the width of the given string using the given font. If `:size` is
    # not specified as one of the options, the string is measured using the
    # current font size. You can also pass `:kerning` as an option to indicate
    # whether kerning should be used when measuring the width (defaults to
    # `false`).
    #
    # Note that the string _must_ be encoded properly for the font being used.
    # For AFM fonts, this is WinAnsi. For TTF/OTF, make sure the font is encoded
    # as UTF-8. You can use the Font#normalize_encoding method to make sure
    # strings are in an encoding appropriate for the current font.
    #
    # @devnote
    #   For the record, this method used to be a method of Font (and still
    #   delegates to width computations on Font). However, having the primary
    #   interface for calculating string widths exist on Font made it tricky to
    #   write extensions for Prawn in which widths are computed differently
    #   (e.g., taking formatting tags into account, or the like).
    #
    #   By putting width_of here, on Document itself, extensions may easily
    #   override it and redefine the width calculation behavior.
    #
    # @param string [String]
    # @param options [Hash{Symbol => any}]
    # @option options :inline_format [Boolean] (false)
    # @option options :kerning [Boolean] (false)
    # @option options :style [Symbol]
    # @return [Number]
    def width_of(string, options = {})
      if options.key?(:inline_format)
        p = options[:inline_format]
        p = [] unless p.is_a?(Array)

        # Build up an Arranger with the entire string on one line, finalize it,
        # and find its width.
        arranger = Prawn::Text::Formatted::Arranger.new(self, options)
        arranger.consumed = text_formatter.format(string, *p)
        arranger.finalize_line

        arranger.line_width
      else
        width_of_string(string, options)
      end
    end

    # Hash that maps font family names to their styled individual font
    # definitions.
    #
    # To add support for another font family, append to this hash, e.g:
    #
    # ```ruby
    # pdf.font_families.update(
    #   "MyTrueTypeFamily" => {
    #     bold: "foo-bold.ttf",
    #     italic: "foo-italic.ttf",
    #     bold_italic: "foo-bold-italic.ttf",
    #     normal: "foo.ttf",
    #   }
    # )
    # ```
    #
    # This will then allow you to use the fonts like so:
    #
    # ```ruby
    # pdf.font("MyTrueTypeFamily", style: :bold)
    # pdf.text "Some bold text"
    # pdf.font("MyTrueTypeFamily")
    # pdf.text "Some normal text"
    # ```
    #
    # This assumes that you have appropriate TTF/OTF fonts for each style you
    # wish to support.
    #
    # By default the styles `:bold`, `:italic`, `:bold_italic`, and `:normal`
    # are defined for fonts "Courier", "Times-Roman" and "Helvetica". When
    # defining your own font families, you can map any or all of these styles to
    # whatever font files you'd like.
    #
    # Font definition can be either a hash or just a string.
    #
    # A hash font definition can specify a number of options:
    #
    # - `:file` -- path to the font file (required)
    # - `:subset` -- whether to subset the font (default false). Only
    #   applicable to TrueType and OpenType fonts (includnig DFont and TTC).
    #
    # A string font definition is equivalent to hash definition with only
    # `:file` being specified.
    #
    # @return [Hash{String => Hash{Symbol => String, Hash{Symbol => String}}}]
    def font_families
      @font_families ||= {}.merge!(
        'Courier' => {
          bold: 'Courier-Bold',
          italic: 'Courier-Oblique',
          bold_italic: 'Courier-BoldOblique',
          normal: 'Courier',
        },

        'Times-Roman' => {
          bold: 'Times-Bold',
          italic: 'Times-Italic',
          bold_italic: 'Times-BoldItalic',
          normal: 'Times-Roman',
        },

        'Helvetica' => {
          bold: 'Helvetica-Bold',
          italic: 'Helvetica-Oblique',
          bold_italic: 'Helvetica-BoldOblique',
          normal: 'Helvetica',
        },
      )
    end

    # @group Experimental API

    # Sets the font directly, given an actual {Font} object and size.
    #
    # @private
    # @param font [Font]
    # @param size [Number]
    # @return [void]
    def set_font(font, size = nil)
      @font = font
      @font_size = size if size
    end

    # Saves the current font, and then yields. When the block finishes, the
    # original font is restored.
    #
    # @yield
    # @return [void]
    def save_font
      @font ||= find_font('Helvetica')
      original_font = @font
      original_size = @font_size

      yield
    ensure
      set_font(original_font, original_size) if original_font
    end

    # Looks up the given font using the given criteria. Once a font has been
    # found by that matches the criteria, it will be cached to subsequent
    # lookups for that font will return the same object.
    #
    # @devnote
    #   Challenges involved: the name alone is not sufficient to uniquely
    #   identify a font (think dfont suitcases that can hold multiple different
    #   fonts in a single file). Thus, the `:name` key is included in the cache
    #   key.
    #
    #   It is further complicated, however, since fonts in some formats (like
    #   the dfont suitcases) can be identified either by numeric index, OR by
    #   their name within the suitcase, and both should hash to the same font
    #   object (to avoid the font being embedded multiple times). This is not
    #   yet implemented, which means if someone selects a font both by name, and
    #   by index, the font will be embedded twice. Since we do font subsetting,
    #   this double embedding won't be catastrophic, just annoying.
    #
    # @private
    # @param name [String]
    # @param options [Hash]
    # @option options :style [Symbol]
    # @option options :file [String]
    # @option options :font [Integer, String] index or name of the font in
    #   a font suitcase/collection
    # @return [Font]
    def find_font(name, options = {}) # :nodoc:
      if font_families.key?(name)
        family = name
        name = font_families[name][options[:style] || :normal]
        if name.is_a?(::Hash)
          options = options.merge(name)
          name = options[:file]
        end
      end
      key = "#{family}:#{name}:#{options[:font] || 0}"

      if name.is_a?(Prawn::Font)
        font_registry[key] = name
      else
        font_registry[key] ||=
          Font.load(self, name, options.merge(family: family))
      end
    end

    # Hash of Font objects keyed by names.
    #
    # @private
    # @return [Hash{String => Font}]
    def font_registry
      @font_registry ||= {}
    end

    private

    def width_of_inline_formatted_string(string, options = {})
      # Build up an Arranger with the entire string on one line, finalize it,
      # and find its width.
      arranger = Prawn::Text::Formatted::Arranger.new(self, options)
      arranger.consumed = Text::Formatted::Parser.format(string)
      arranger.finalize_line

      arranger.line_width
    end

    def width_of_string(string, options = {})
      font_metric_cache.width_of(string, options)
    end
  end

  # Provides font information and helper functions.
  #
  # @abstract
  class Font
    require_relative 'fonts'

    # @deprecated
    AFM = Prawn::Fonts::AFM

    # @deprecated
    TTF = Fonts::TTF

    # @deprecated
    DFont = Fonts::DFont

    # @deprecated
    TTC = Fonts::TTC

    # The font name.
    # @return [String]
    attr_reader :name

    # The font family.
    # @return [String]
    attr_reader :family

    # The options hash used to initialize the font.
    # @return [Hash]
    attr_reader :options

    # Shortcut interface for constructing a font object. Filenames of the form
    # `*.ttf` will call {Fonts::TTF#initialize TTF.new}, `*.otf` calls
    # {Fonts::OTF#initialize OTF.new}, `*.dfont` calls {Fonts::DFont#initialize
    # DFont.new}, `*.ttc` goes to {Fonts::TTC#initialize TTC.new}, and anything
    # else will be passed through to {Prawn::Fonts::AFM#initialize AFM.new}.
    #
    # @param document [Prawn::Document] owning document
    # @param src [String] font file path
    # @param options [Hash]
    # @option options :family [String]
    # @option options :style [Symbol]
    # @return [Prawn::Fonts::Font]
    def self.load(document, src, options = {})
      case font_format(src, options)
      when 'ttf' then TTF.new(document, src, options)
      when 'otf' then Fonts::OTF.new(document, src, options)
      when 'dfont' then DFont.new(document, src, options)
      when 'ttc' then TTC.new(document, src, options)
      else AFM.new(document, src, options)
      end
    end

    # Guesses font format.
    #
    # @private
    # @param src [String, IO]
    # @param options [Hash]
    # @option options :format [String]
    # @return [String]
    def self.font_format(src, options)
      return options.fetch(:format, 'ttf') if src.respond_to?(:read)

      case src.to_s
      when /\.ttf$/i then 'ttf'
      when /\.otf$/i then 'otf'
      when /\.dfont$/i then 'dfont'
      when /\.ttc$/i then 'ttc'
      else 'afm'
      end
    end

    # @private
    # @param document [Prawn::Document]
    # @param name [String]
    # @param options [Hash{Symbol => any}]
    # @option options :family [String]
    # @option options :subset [Boolean] (true)
    def initialize(document, name, options = {})
      @document = document
      @name = name
      @options = options

      @family = options[:family]

      @identifier = generate_unique_id

      @references = {}
      @subset_name_cache = {}

      @full_font_embedding = options.key?(:subset) && !options[:subset]
    end

    # The size of the font ascender in PDF points.
    #
    # @return [Number]
    def ascender
      @ascender / 1000.0 * size
    end

    # The size of the font descender in PDF points.
    #
    # @return [Number]
    def descender
      -@descender / 1000.0 * size
    end

    # The size of the recommended gap between lines of text in PDF points
    #
    # @return [Number]
    def line_gap
      @line_gap / 1000.0 * size
    end

    # Normalizes the encoding of the string to an encoding supported by the
    # font. The string is expected to be UTF-8 going in. It will be re-encoded
    # and the new string will be returned.
    #
    # @abstract
    # @!parse def normalize_encoding(string); end
    # @param string [String]
    # @return [String]
    def normalize_encoding(_string)
      raise NotImplementedError,
        'subclasses of Prawn::Font must implement #normalize_encoding'
    end

    # Destructive version of {normalize_encoding}; normalizes the encoding of a
    # string in place.
    #
    # @note This method doesn't mutate its argument any more.
    #
    # @deprecated
    # @param str [String]
    # @return [String]
    def normalize_encoding!(str)
      warn('Font#normalize_encoding! is deprecated. Please use non-mutating version Font#normalize_encoding instead.')
      str.dup.replace(normalize_encoding(str))
    end

    # Gets height of font in PDF points at the given font size.
    #
    # @param size [Number]
    # @return [Number]
    def height_at(size)
      @normalized_height ||= (@ascender - @descender + @line_gap) / 1000.0
      @normalized_height * size
    end

    # Gets height of current font in PDF points at current font size.
    #
    # @return [Number]
    def height
      height_at(size)
    end

    # Registers the given subset of the current font with the current PDF
    # page. This is safe to call multiple times for a given font and subset,
    # as it will only add the font the first time it is called.
    #
    # @param subset [Integer]
    # @return [void]
    def add_to_current_page(subset)
      @references[subset] ||= register(subset)
      @document.state.page.fonts[identifier_for(subset)] = @references[subset]
    end

    # @private
    # @param subset [Integer]
    # @return [Symbol]
    def identifier_for(subset)
      @subset_name_cache[subset] ||=
        if full_font_embedding
          @identifier.to_sym
        else
          :"#{@identifier}.#{subset}"
        end
    end

    # Returns a string containing a human-readable representation of this font.
    #
    # @return [String]
    def inspect
      "#{self.class.name}< #{name}: #{size} >"
    end

    # Return a hash (as in `Object#hash`) for the font. This is required since
    # font objects are used as keys in hashes that cache certain values.
    #
    # @return [Integer]
    def hash
      [self.class, name, family].hash
    end

    # Compliments the {#hash} implementation.
    #
    # @param other [Object]
    # @return [Boolean]
    def eql?(other)
      self.class == other.class && name == other.name &&
        family == other.family && size == other.size
    end

    private

    attr_reader :full_font_embedding

    # generate a font identifier that hasn't been used on the current page yet
    #
    def generate_unique_id
      key = nil
      font_count = @document.font_registry.size + 1
      loop do
        key = :"F#{font_count}"
        break if key_is_unique?(key)

        font_count += 1
      end
      key
    end

    def key_is_unique?(test_key)
      @document.state.page.fonts.keys.none? do |key|
        key.to_s.start_with?("#{test_key}.")
      end
    end

    protected

    def size
      @document.font_size
    end
  end
end
