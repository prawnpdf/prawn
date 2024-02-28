# frozen_string_literal: true

require_relative '../encoding'

module Prawn
  module Fonts
    # AFM font. AFM stands for Adobe Font Metrics. It's not a complete font, it
    # doesn't provide actual glyph outlines. It only contains glyph metrics to
    # make text layout possible. AFM is used for PDF built-in fonts. Those
    # fonts are supposed to be present on the target system making it possible
    # to save a little bit of space by not embedding the fonts. A file that uses
    # these fonts can not be read on a system that doesn't have these fonts
    # installed.
    #
    # @note You shouldn't use this class directly.
    class AFM < Font
      class << self
        # Prawn would warn you if you're using non-ASCII glyphs with AFM fonts
        # as not all implementations provide those glyphs. This attribute
        # suppresses that warning.
        #
        # @return [Boolean] (false)
        attr_accessor :hide_m17n_warning
      end

      self.hide_m17n_warning = false

      # List of PDF built-in fonts.
      BUILT_INS = %w[
        Courier Helvetica Times-Roman Symbol ZapfDingbats
        Courier-Bold Courier-Oblique Courier-BoldOblique
        Times-Bold Times-Italic Times-BoldItalic
        Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique
      ].freeze

      # Does this font support Unicode?
      #
      # @return [false]
      def unicode?
        false
      end

      # Paths to look for AFM files at.
      #
      # @return [Array<String>]
      def self.metrics_path
        @metrics_path ||=
          if ENV['METRICS']
            ENV['METRICS'].split(':')
          else
            [
              '.', '/usr/lib/afm',
              '/usr/local/lib/afm',
              '/usr/openwin/lib/fonts/afm',
              "#{Prawn::DATADIR}/fonts",
            ]
          end
      end

      # @private
      attr_reader :attributes

      # Parsed AFM data cache.
      #
      # @return [SynchronizedCache]
      def self.font_data
        @font_data ||= SynchronizedCache.new
      end

      # @param document [Prawn::Document]
      # @param name [String]
      # @param options [Hash]
      # @option options :family [String]
      # @option options :style [Symbol]
      def initialize(document, name, options = {})
        name ||= options[:family]
        unless BUILT_INS.include?(name)
          raise Prawn::Errors::UnknownFont,
            "#{name} (#{options[:style] || 'normal'}) is not a known font."
        end

        super

        file_name = @name.dup
        file_name << '.afm' unless /\.afm$/.match?(file_name)
        file_name = find_font(file_name) unless file_name[0] == '/'

        font_data = self.class.font_data[file_name] ||= parse_afm(file_name)
        @glyph_widths = font_data[:glyph_widths]
        @glyph_table = font_data[:glyph_table]
        @bounding_boxes = font_data[:bounding_boxes]
        @kern_pairs = font_data[:kern_pairs]
        @kern_pair_table = font_data[:kern_pair_table]
        @attributes = font_data[:attributes]

        @ascender = Integer(@attributes.fetch('ascender', '0'), 10)
        @descender = Integer(@attributes.fetch('descender', '0'), 10)
        @line_gap = Float(bbox[3] - bbox[1]) - (@ascender - @descender)
      end

      # The font bbox.
      #
      # @return [Array(Number, Number, Number, Number)]
      def bbox
        @bbox ||= @attributes['fontbbox'].split(/\s+/).map { |e| Integer(e) }
      end

      # Compute width of a string at the specified size, optionally with kerning
      # applied.
      #
      # @param string [String] *must* be encoded as WinAnsi
      # @param options [Hash{Symbol => any}]
      # @option options :size [Number]
      # @option options :kerning [Boolean] (false)
      # @return [Number]
      def compute_width_of(string, options = {})
        scale = (options[:size] || size) / 1000.0

        if options[:kerning]
          strings, numbers = kern(string).partition { |e| e.is_a?(String) }
          total_kerning_offset = numbers.sum
          (unscaled_width_of(strings.join) - total_kerning_offset) * scale
        else
          unscaled_width_of(string) * scale
        end
      end

      # Does this font contain kerning data.
      #
      # @return [Boolean]
      def has_kerning_data? # rubocop: disable Naming/PredicateName
        @kern_pairs.any?
      end

      # Built-in fonts only work with WinAnsi encoding, so translate the
      # string. Changes the encoding in-place, so the argument itself
      # is replaced with a string in WinAnsi encoding.
      #
      # @param text [String]
      # @return [String]
      def normalize_encoding(text)
        text.encode('windows-1252')
      rescue ::Encoding::InvalidByteSequenceError,
             ::Encoding::UndefinedConversionError

        raise Prawn::Errors::IncompatibleStringEncoding,
          "Your document includes text that's not compatible with the " \
            "Windows-1252 character set.\n" \
            'If you need full UTF-8 support, use external fonts instead of ' \
            "PDF's built-in fonts.\n"
      end

      # Encode text to UTF-8.
      #
      # @param text [String]
      # @return [String]
      def to_utf8(text)
        text.encode('UTF-8')
      end

      # Returns the number of characters in `str` (a WinAnsi-encoded string).
      #
      # @param str [String]
      # @return [Integer]
      def character_count(str)
        str.length
      end

      # Perform any changes to the string that need to happen
      # before it is rendered to the canvas. Returns an array of
      # subset "chunks", where each chunk is an array of two elements.
      # The first element is the font subset number, and the second
      # is either a string or an array (for kerned text).
      #
      # For Adobe fonts, there is only ever a single subset, so
      # the first element of the array is `0`, and the second is
      # the string itself (or an array, if kerning is performed).
      #
      # The `text` argument must be in WinAnsi encoding (cp1252).
      #
      # @param text [String]
      # @param options [Hash{Symbol => any}]
      # @option options :kerning [Boolean]
      # @return [Array<Array(0, (String, Array)>]
      def encode_text(text, options = {})
        [[0, options[:kerning] ? kern(text) : text]]
      end

      # Does this font has a glyph for the character?
      #
      # @param char [String]
      # @return [Boolean]
      def glyph_present?(char)
        !normalize_encoding(char).nil?
      rescue Prawn::Errors::IncompatibleStringEncoding
        false
      end

      private

      def register(_subset)
        font_dict = {
          Type: :Font,
          Subtype: :Type1,
          BaseFont: name.to_sym,
        }

        # Symbolic AFM fonts (Symbol, ZapfDingbats) have their own encodings
        font_dict[:Encoding] = :WinAnsiEncoding unless symbolic?

        @document.ref!(font_dict)
      end

      def symbolic?
        attributes['characterset'] == 'Special'
      end

      def find_font(file)
        self.class.metrics_path.find { |f| File.exist?("#{f}/#{file}") } +
          "/#{file}"
      rescue NoMethodError
        raise Prawn::Errors::UnknownFont,
          "Couldn't find the font: #{file} in any of:\n" +
            self.class.metrics_path.join("\n")
      end

      def parse_afm(file_name)
        data = {
          glyph_widths: {},
          bounding_boxes: {},
          kern_pairs: {},
          attributes: {},
        }
        section = []

        File.foreach(file_name) do |line|
          case line
          when /^Start(\w+)/
            section.push(Regexp.last_match(1))
            next
          when /^End(\w+)/
            section.pop
            next
          end

          case section
          when %w[FontMetrics CharMetrics]
            next unless /^CH?\s/.match?(line)

            name = line[/\bN\s+(\.?\w+)\s*;/, 1]
            data[:glyph_widths][name] = Integer(line[/\bWX\s+(\d+)\s*;/, 1], 10)
            data[:bounding_boxes][name] = line[/\bB\s+([^;]+);/, 1].to_s.rstrip
          when %w[FontMetrics KernData KernPairs]
            next unless line =~ /^KPX\s+(\.?\w+)\s+(\.?\w+)\s+(-?\d+)/

            data[:kern_pairs][[Regexp.last_match(1), Regexp.last_match(2)]] =
              Integer(Regexp.last_match(3), 10)
          when %w[FontMetrics KernData TrackKern],
            %w[FontMetrics Composites]
            next
          else
            parse_generic_afm_attribute(line, data)
          end
        end

        # process data parsed from AFM file to build tables which
        #   will be used when measuring and kerning text
        data[:glyph_table] =
          (0..255).map { |i|
            data[:glyph_widths].fetch(Encoding::WinAnsi::CHARACTERS[i], 0)
          }

        character_hash = Encoding::WinAnsi::CHARACTERS.zip((0..Encoding::WinAnsi::CHARACTERS.size).to_a).to_h
        data[:kern_pair_table] =
          data[:kern_pairs].each_with_object({}) do |p, h|
            h[p[0].map { |n| character_hash[n] }] = p[1]
          end

        data.each_value(&:freeze)
        data.freeze
      end

      def parse_generic_afm_attribute(line, hash)
        line =~ /(^\w+)\s+(.*)/
        key = Regexp.last_match(1).to_s.downcase
        value = Regexp.last_match(2)

        hash[:attributes][key] =
          if hash[:attributes][key]
            Array(hash[:attributes][key]) << value
          else
            value
          end
      end

      # converts a string into an array with spacing offsets
      # between characters that need to be kerned
      #
      # String *must* be encoded as WinAnsi
      #
      def kern(string)
        kerned = [[]]
        last_byte = nil

        string.each_byte do |byte|
          k = last_byte && @kern_pair_table[[last_byte, byte]]
          if k
            kerned << -k << [byte]
          else
            kerned.last << byte
          end
          last_byte = byte
        end

        kerned.map do |e|
          e = e.pack('C*') if e.is_a?(Array)
          if e.respond_to?(:force_encoding)
            e.force_encoding(::Encoding::Windows_1252)
          else
            e
          end
        end
      end

      def unscaled_width_of(string)
        string.bytes.reduce(0) do |s, r|
          s + @glyph_table[r]
        end
      end
    end
  end
end
