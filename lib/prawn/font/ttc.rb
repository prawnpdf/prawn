# font.rb : The Prawn font class
#
# Copyright November 2008, Jamis Buck. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
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
            list << font.name.font_name.join(', ')
          end

          list
        end
      end

      private

      def read_ttf_file
        TTFunk::File.from_ttc(@name, @options[:font] || 0)
      end
    end
  end
end
