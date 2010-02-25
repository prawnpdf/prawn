# encoding: utf-8
#
# font.rb : The Prawn font class
#
# Copyright November 2008, Jamis Buck. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
require 'prawn/font/ttf'

module Prawn
  class Font
    class DFont < TTF
      
      # Returns a list of the names of all named fonts in the given dfont file.
      # Note that fonts are not required to be named in a dfont file, so the
      # list may be empty even if the file does contain fonts. Also, note that
      # the list is returned in no particular order, so the first font in the
      # list is not necessarily the font at index 0 in the file.
      #
      def self.named_fonts(file)
        TTFunk::ResourceFile.open(file) do |f|
          return f.resources_for("sfnt")
        end
      end

      # Returns the number of fonts contained in the dfont file.
      #
      def self.font_count(file)
        TTFunk::ResourceFile.open(file) do |f|
          return f.map["sfnt"][:list].length
        end
      end

      private 

      def read_ttf_file
        TTFunk::File.from_dfont(@name, @options[:font] || 0)
      end
    end
  end
end
