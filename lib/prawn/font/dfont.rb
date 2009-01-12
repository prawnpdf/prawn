require 'prawn/font/ttf'

module Prawn
  class Font
    class DFont < TTF
      def self.each_named_font(file)
        TTFunk::ResourceFile.open(file) do |file|
          file.resources_for("sfnt").each do |name|
            yield name
          end
        end
      end

      def self.font_count(file)
        TTFunk::ResourceFile.open(file) do |file|
          return file.map["sfnt"][:list].length
        end
      end

      private 

      def read_ttf_file
        TTFunk::File.from_dfont(@name, @options[:select] || 0)
      end
    end
  end
end
