# frozen_string_literal: true

require_relative 'ttf'

module Prawn
  module Fonts
    # TrueType Collection font. It's an SFNT-based format that contains a bunch
    # of TrueType fonts in a single file.
    #
    # @note You shouldn't use this class directly.
    class TTC < TTF
      # Returns a list of the names of all named fonts in the given ttc file.
      # They are returned in order of their appearance in the file.
      #
      # @param file [String]
      # @return [Array<String>]
      def self.font_names(file)
        TTFunk::Collection.open(file) do |ttc|
          ttc.map { |font| font.name.font_name.first }
        end
      end

      private

      def read_ttf_file
        TTFunk::File.from_ttc(
          @name,
          font_option_to_index(@name, @options[:font]),
        )
      end

      def font_option_to_index(file, option)
        if option.is_a?(Numeric)
          option
        else
          self.class.font_names(file).index { |n| n == option } || 0
        end
      end
    end
  end
end
