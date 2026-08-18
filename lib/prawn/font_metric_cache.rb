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

      # Key on f.object_id, not f itself: Font#hash/#eql? do real work (a
      # fresh Array + Array#hash, plus 4 field comparisons on collision) on
      # every single lookup, for every call to #width_of -- i.e. per text
      # fragment measured, which for a large table is a lot of calls. Font
      # instances for a given family/style are already memoized by identity
      # in Document#find_font's font_registry, so object identity is exactly
      # as precise as Font's own value-equality here, at a fraction of the
      # cost (Integer#hash/#eql? instead of Array allocation + comparisons).
      key = CacheEntry.new(f.object_id, @document.font_size, options, encoded_string)

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
