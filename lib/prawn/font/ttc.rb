require_relative 'ttf'

module Prawn
  class Font
    # @private
    class TTC < TTF
      # Returns a list of the names of all named fonts in the given ttc file.
      # They are returned in order of their appearance in the file.
      #
      def self.fonts(file)
        TTFunk::Collection.open(file) do |f|
          list = []

          f.each do |font|
            list << font.name.font_name.first
          end

          list
        end
      end

      private

      def read_ttf_file
        TTFunk::File.from_ttc(@name,
          font_option_to_index(@name, @options[:font]))
      end

      def font_option_to_index(file, option)
        if option.is_a?(Numeric)
          option
        else
          self.class.fonts(file).index { |n| n == option } || 0
        end
      end
    end
  end
end
