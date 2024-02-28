# frozen_string_literal: true

# prawn/font/ttf.rb : Implements AFM font support for Prawn
#
# Copyright May 2008, Gregory Brown / James Healy / Jamis Buck
# All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'ttfunk'
require 'ttfunk/subset_collection'
require_relative 'to_unicode_cmap'

module Prawn
  module Fonts
    # TrueType font.
    #
    # @note You shouldn't use this class directly.
    class TTF < Font
      # TrueType font error.
      class Error < StandardError
        # @private
        DEFAULT_MESSAGE = 'TTF font error'

        # @private
        MESSAGE_WITH_FONT = 'TTF font error in font %<font>s'

        def initialize(message = DEFAULT_MESSAGE, font: nil)
          if font && message == DEFAULT_MESSAGE
            super(format(MESSAGE_WITH_FONT, font: font))
          else
            super(message)
          end
        end
      end

      # Signals absence of a Unicode character map in the font.
      class NoUnicodeCMap < Error
        # @private
        DEFAULT_MESSAGE = 'No unicode cmap found in font'

        # @private
        MESSAGE_WITH_FONT = 'No unicode cmap found in font %<font>s'
      end

      # Signals absense of a PostScript font name.
      class NoPostscriptName < Error
        # @private
        DEFAULT_MESSAGE = 'Can not detect a postscript name'

        # @private
        MESSAGE_WITH_FONT = 'Can not detect a postscript name in font %<font>s'
      end

      # TTFunk font.
      # @return [TTFunk::File]
      attr_reader :ttf
      attr_reader :subsets

      # Does this font support Unicode?
      #
      # @return [true]
      def unicode?
        true
      end

      # An adapter for subset collection to represent a full font.
      #
      # @private
      class FullFontSubsetsCollection
        FULL_FONT = Object.new.tap do |obj|
          obj.singleton_class.define_method(:inspect) do
            super().insert(-2, ' FULL_FONT')
          end
        end.freeze

        def initialize(original)
          @original = original

          (@cmap ||= original.cmap.unicode.first) || raise(NoUnicodeCMap.new(font: name))

          @code_space_size =
            case cmap.code_map.keys.max
            when 0..0xff then 1
            when 0x100..0xffff then 2
            when 0x10000..0xffffff then 3
            else
              4
            end

          # Codespaces are not sequentional, they're ranges in
          # a multi-dimentional space. Each byte is considered separately. So we
          # have to maximally extend the lower two bytes in order to allow for
          # continuos Unicode mapping.
          # We only keep the highest byte because Unicode only goes to 1FFFFF
          # and fonts usually cover even less of the space. We don't want to
          # list all those unmapped charac codes here.
          @code_space_max = cmap.code_map.keys.max | ('ff' * (code_space_size - 1)).to_i(16)
        end

        # Encode characters.
        #
        # @return [Array<Array(FULL_FONT, String)>]
        def encode(characters)
          [
            [
              FULL_FONT,
              characters.map { |c|
                check_bounds!(c)
                [cmap[c]].pack('n')
              }.join(''),
            ],
          ]
        end

        private

        attr_reader :cmap
        attr_reader :code_space_size
        attr_reader :code_space_max

        def check_bounds!(num)
          if num > code_space_max
            raise Error, "CID (#{num}) exceedes code space size"
          end
        end
      end

      # @param document [Prawn::Document]
      # @param name [String] font file path
      # @param options [Hash]
      # @option options :family [String]
      # @option options :style [Symbol]
      def initialize(document, name, options = {})
        super

        @ttf = read_ttf_file
        @subsets =
          if full_font_embedding
            FullFontSubsetsCollection.new(@ttf)
          else
            TTFunk::SubsetCollection.new(@ttf)
          end
        @italic_angle = nil

        @attributes = {}
        @bounding_boxes = {}
        @char_widths = {}
        @has_kerning_data = @ttf.kerning.exists? && @ttf.kerning.tables.any?

        @ascender = Integer(@ttf.ascent * scale_factor)
        @descender = Integer(@ttf.descent * scale_factor)
        @line_gap = Integer(@ttf.line_gap * scale_factor)
      end

      # Compute width of a string at the specified size, optionally with kerning
      # applied.
      #
      # @param string [String] *must* be encoded as UTF-8
      # @param options [Hash{Symbol => any}]
      # @option options :size [Number]
      # @option options :kerning [Boolean] (false)
      # @return [Number]
      def compute_width_of(string, options = {})
        scale = (options[:size] || size) / 1000.0
        if options[:kerning]
          kern(string).reduce(0) { |s, r|
            if r.is_a?(Numeric)
              s - r
            else
              r.reduce(s) { |a, e| a + character_width_by_code(e) }
            end
          } * scale
        else
          string.codepoints.reduce(0) { |s, r|
            s + character_width_by_code(r)
          } * scale
        end
      end

      # The font bbox.
      #
      # @return [Array(Number, Number, Number, Number)]
      def bbox
        @bbox ||= @ttf.bbox.map { |i| Integer(i * scale_factor) }
      end

      # Does this font contain kerning data.
      #
      # @return [Boolean]
      def has_kerning_data? # rubocop: disable Naming/PredicateName
        @has_kerning_data
      end

      # Perform any changes to the string that need to happen before it is
      # rendered to the canvas. Returns an array of subset "chunks", where the
      # even-numbered indices are the font subset number, and the following
      # entry element is either a string or an array (for kerned text).
      #
      # @param text [String] must be in UTF-8 encoding
      # @param options [Hash{Symbol => any}]
      # @option options :kerning [Boolean]
      # @return [Array<Array(0, (String, Array)>]
      def encode_text(text, options = {})
        text = text.chomp

        if options[:kerning]
          last_subset = nil
          kern(text).reduce([]) do |result, element|
            if element.is_a?(Numeric)
              unless result.last[1].is_a?(Array)
                result.last[1] = [result.last[1]]
              end
              result.last[1] << element
              result
            else
              encoded = @subsets.encode(element)

              if encoded.first[0] == last_subset
                result.last[1] << encoded.first[1]
                encoded.shift
              end

              if encoded.any?
                last_subset = encoded.last[0]
                result + encoded
              else
                result
              end
            end
          end
        else
          @subsets.encode(text.unpack('U*'))
        end
      end

      # Base name of the font.
      #
      # @return [String]
      def basename
        @basename ||= @ttf.name.postscript_name
      end

      # @devnote not sure how to compute this for true-type fonts...
      #
      # @private
      # @return [Number]
      def stem_v
        0
      end

      # @private
      # @return [Number]
      def italic_angle
        return @italic_angle if @italic_angle

        if @ttf.postscript.exists?
          raw = @ttf.postscript.italic_angle
          hi = raw >> 16
          low = raw & 0xFF
          hi = -((hi ^ 0xFFFF) + 1) if hi & 0x8000 != 0
          @italic_angle = Float("#{hi}.#{low}")
        else
          @italic_angle = 0
        end

        @italic_angle
      end

      # @private
      # @return [Number]
      def cap_height
        @cap_height ||=
          begin
            height = (@ttf.os2.exists? && @ttf.os2.cap_height) || 0
            height.zero? ? @ascender : height
          end
      end

      # @private
      # @return [number]
      def x_height
        # FIXME: seems like if os2 table doesn't exist, we could
        # just find the height of the lower-case 'x' glyph?
        (@ttf.os2.exists? && @ttf.os2.x_height) || 0
      end

      # @private
      # @return [Number]
      def family_class
        @family_class ||= ((@ttf.os2.exists? && @ttf.os2.family_class) || 0) >> 8
      end

      # @private
      # @return [Boolean]
      def serif?
        @serif ||= [1, 2, 3, 4, 5, 7].include?(family_class)
      end

      # @private
      # @return [Boolean]
      def script?
        @script ||= family_class == 10
      end

      # @private
      # @return [Integer]
      def pdf_flags
        @pdf_flags ||=
          begin
            flags = 0
            flags |= 0x0001 if @ttf.postscript.fixed_pitch?
            flags |= 0x0002 if serif?
            flags |= 0x0008 if script?
            flags |= 0x0040 if italic_angle != 0
            # Assume the font contains at least some non-latin characters
            flags | 0x0004
          end
      end

      # Normlize text to a compatible encoding.
      #
      # @param text [String]
      # @return [String]
      def normalize_encoding(text)
        text.encode(::Encoding::UTF_8)
      rescue StandardError
        raise Prawn::Errors::IncompatibleStringEncoding,
          "Encoding #{text.encoding} can not be transparently converted to UTF-8. " \
            'Please ensure the encoding of the string you are attempting to use is set correctly'
      end

      # Encode text to UTF-8.
      #
      # @param text [String]
      # @return [String]
      def to_utf8(text)
        text.encode('UTF-8')
      end

      # Does this font has a glyph for the character?
      #
      # @param char [String]
      # @return [Boolean]
      def glyph_present?(char)
        code = char.codepoints.first
        cmap[code].positive?
      end

      # Returns the number of characters in `str` (a UTF-8-encoded string).
      #
      # @param str [String]
      # @return [Integer]
      def character_count(str)
        str.length
      end

      private

      def cmap
        (@cmap ||= @ttf.cmap.unicode.first) || raise(NoUnicodeCMap.new(font: name))
      end

      # +string+ must be UTF8-encoded.
      #
      # Returns an array. If an element is a numeric, it represents the
      # kern amount to inject at that position. Otherwise, the element
      # is an array of UTF-16 characters.
      def kern(string)
        a = []

        string.each_codepoint do |r|
          if a.empty?
            a << [r]
          elsif (kern = kern_pairs_table[[cmap[a.last.last], cmap[r]]])
            kern *= scale_factor
            a << -kern << [r]
          else
            a.last << r
          end
        end

        a
      end

      def kern_pairs_table
        @kern_pairs_table ||=
          if has_kerning_data?
            @ttf.kerning.tables.first.pairs
          else
            {}
          end
      end

      def hmtx
        @hmtx ||= @ttf.horizontal_metrics
      end

      def character_width_by_code(code)
        return 0 unless cmap[code]

        # Some TTF fonts have nonzero widths for \n (UTF-8 / ASCII code: 10).
        # Patch around this as we'll never be drawing a newline with a width.
        return 0.0 if code == 10

        @char_widths[code] ||= Integer(hmtx.widths[cmap[code]] * scale_factor)
      end

      def scale_factor
        @scale_factor ||= 1000.0 / @ttf.header.units_per_em
      end

      def register(subset)
        temp_name = @ttf.name.postscript_name.delete("\0").to_sym
        ref = @document.ref!(Type: :Font, BaseFont: temp_name)

        # Embed the font metrics in the document after everything has been
        # drawn, just before the document is emitted.
        @document.renderer.before_render { |_doc| embed(ref, subset) }

        ref
      end

      def embed(reference, subset)
        if full_font_embedding
          embed_full_font(reference)
        else
          embed_subset(reference, subset)
        end
      end

      def embed_subset(reference, subset)
        font = TTFunk::File.new(@subsets[subset].encode)
        unicode_mapping = @subsets[subset].to_unicode_map
        embed_simple_font(reference, font, unicode_mapping)
      end

      def embed_simple_font(reference, font, unicode_mapping)
        if font_type(font) == :unknown
          raise Error, %(Simple font embedding is not uspported for font "#{font.name}.")
        end

        true_type = font_type(font) == :true_type
        open_type = font_type(font) == :open_type

        # empirically, it looks like Adobe Reader will not display fonts
        # if their font name is more than 33 bytes long. Strange. But true.
        basename = font.name.postscript_name[0, 33].delete("\0")

        raise NoPostscriptName.new(font: font) if basename.nil?

        fontfile = @document.ref!({})
        fontfile.data[:Length1] = font.contents.size
        fontfile.stream << font.contents.string
        fontfile.stream.compress! if @document.compression_enabled?

        descriptor = @document.ref!(
          Type: :FontDescriptor,
          FontName: basename.to_sym,
          FontBBox: bbox,
          Flags: pdf_flags,
          StemV: stem_v,
          ItalicAngle: italic_angle,
          Ascent: @ascender,
          Descent: @descender,
          CapHeight: cap_height,
          XHeight: x_height,
        )

        first_char, last_char = unicode_mapping.keys.minmax
        hmtx = font.horizontal_metrics
        widths =
          (first_char..last_char).map { |code|
            if unicode_mapping.key?(code)
              gid = font.cmap.tables.first.code_map[code]
              Integer(hmtx.widths[gid] * scale_factor)
            else
              # These characters are not in the document so we don't ever use
              # these values but we need to encode them so let's use as little
              # sapce as possible.
              0
            end
          }

        # It would be nice to have Encoding set for the macroman subsets,
        # and only do a ToUnicode cmap for non-encoded unicode subsets.
        # However, apparently Adobe Reader won't render MacRoman encoded
        # subsets if original font contains unicode characters. (It has to
        # be some flag or something that ttfunk is simply copying over...
        # but I can't figure out which flag that is.)
        #
        # For now, it's simplest to just create a unicode cmap for every font.
        # It offends my inner purist, but it'll do.

        to_unicode = @document.ref!({})
        to_unicode << ToUnicodeCMap.new(unicode_mapping).generate
        to_unicode.stream.compress! if @document.compression_enabled?

        reference.data.update(
          BaseFont: basename.to_sym,
          FontDescriptor: descriptor,
          FirstChar: first_char,
          LastChar: last_char,
          Widths: @document.ref!(widths),
          ToUnicode: to_unicode,
        )

        if true_type
          reference.data.update(Subtype: :TrueType)
          descriptor.data.update(FontFile2: fontfile)
        elsif open_type
          @document.renderer.min_version(1.6)
          reference.data.update(Subtype: :Type1)
          descriptor.data.update(FontFile3: fontfile)
          fontfile.data.update(Subtype: :OpenType)
        end
      end

      def embed_full_font(reference)
        embed_composite_font(reference, @ttf)
      end

      def embed_composite_font(reference, font)
        if font_type(font) == :unknown
          raise Error, %(Composite font embedding is not uspported for font "#{font.name}.")
        end

        true_type = font_type(font) == :true_type
        open_type = font_type(font) == :open_type

        fontfile = @document.ref!({})
        fontfile.data[:Length1] = font.contents.size if true_type
        fontfile.data[:Subtype] = :CIDFontType0C if open_type
        fontfile.stream << font.contents.string
        fontfile.stream.compress! if @document.compression_enabled?

        # empirically, it looks like Adobe Reader will not display fonts
        # if their font name is more than 33 bytes long. Strange. But true.
        basename = font.name.postscript_name[0, 33].delete("\0")

        descriptor = @document.ref!(
          Type: :FontDescriptor,
          FontName: basename.to_sym,
          FontBBox: bbox,
          Flags: pdf_flags,
          StemV: stem_v,
          ItalicAngle: italic_angle,
          Ascent: @ascender,
          Descent: @descender,
          CapHeight: cap_height,
          XHeight: x_height,
        )
        descriptor.data[:FontFile2] = fontfile if true_type
        descriptor.data[:FontFile3] = fontfile if open_type

        to_unicode = @document.ref!({})
        to_unicode << ToUnicodeCMap.new(
          font.cmap.unicode.first
          .code_map
          .reject { |cid, gid| gid.zero? || (0xd800..0xdfff).cover?(cid) }
          .invert
          .sort.to_h,
          2, # Identity-H is a 2-byte encoding
        ).generate
        to_unicode.stream.compress! if @document.compression_enabled?

        widths =
          font.horizontal_metrics.widths.map { |w| (w * scale_factor).round }

        child_font = @document.ref!(
          Type: :Font,
          BaseFont: basename.to_sym,
          CIDSystemInfo: {
            Registry: 'Adobe',
            Ordering: 'Identity',
            Supplement: 0,
          },
          FontDescriptor: descriptor,
          W: [0, widths],
        )
        if true_type
          child_font.data.update(
            Subtype: :CIDFontType2,
            CIDToGIDMap: :Identity,
          )
        end
        if open_type
          child_font.data[:Subtype] = :CIDFontType0
        end

        reference.data.update(
          Subtype: :Type0,
          BaseFont: basename.to_sym,
          Encoding: :'Identity-H',
          DescendantFonts: [child_font],
          ToUnicode: to_unicode,
        )
      end

      def font_type(font)
        if font.directory.tables.key?('glyf')
          :true_type
        elsif font.directory.tables.key?('CFF ')
          :open_type
        else
          :unknown
        end
      end

      def read_ttf_file
        TTFunk::File.open(@name)
      end
    end
  end
end
