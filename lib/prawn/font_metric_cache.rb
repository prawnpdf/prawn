# frozen_string_literal: true

module Prawn
  # Cache used internally by {Prawn::Document} instances to calculate the width
  # of various strings for layout purposes.
  #
  # @private
  class FontMetricCache
    CacheEntry = Struct.new(:font, :font_size, :options, :string)

    def initialize(document)
      @document = document

      @cache = {}
    end

    # Get width of string.
    #
    # @param string [String]
    # @param options [Hash{Symbol => any}]
    # @option options :style [Symbol]
    # @option options :size [Number]
    # @option options :kerning [Boolean] (false)
    # @return [Number]
    def width_of(string, options)
      f =
        if options[:style]
          # override style with :style => :bold
          @document.find_font(@document.font.family, style: options[:style])
        else
          @document.font
        end

      encoded_string = f.normalize_encoding(string)

      key = CacheEntry.new(f, @document.font_size, options, encoded_string)

      @cache[key] ||= f.compute_width_of(encoded_string, options)

      length = @cache[key]

      character_count = @document.font.character_count(encoded_string)
      if character_count.positive?
        length += @document.character_spacing * (character_count - 1)
      end

      length
    end
  end
end
