require 'prawn/font/ttf'

module Prawn
  class Font
    class DFont < TTF
      private 

      def read_ttf_file
        TTFunk::File.from_dfont(@name, @options[:select] || 0)
      end
    end
  end
end
