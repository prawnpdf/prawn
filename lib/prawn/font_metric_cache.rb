# frozen_string_literal: true

module Prawn
  # Cache used internally by {Prawn::Document} instances to calculate the width
  # of various strings for layout purposes.
  #
  # @private
  class FontMetricCache
    def initialize(document)
      @document = document

      # Fonts are keyed by identity: Document#find_font returns the same
      # instance for the same font, and identity lookups are cheap.
      @cache = {}.compare_by_identity
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

      # Font#hash/#eql? do real work on every lookup, so fonts are compared by
      # identity (see #initialize). Font instances are memoized per family and
      # style in Document#find_font, so identity is as precise as equality.
      # Nested hashes avoid allocating and hashing a composite key per call.
      by_string = ((@cache[f] ||= {})[@document.font_size] ||= {})[options] ||= {}
      length = (by_string[encoded_string] ||= f.compute_width_of(encoded_string, options))

      character_count = @document.font.character_count(encoded_string)
      if character_count.positive?
        length += @document.character_spacing * (character_count - 1)
      end

      length
    end
  end
end
