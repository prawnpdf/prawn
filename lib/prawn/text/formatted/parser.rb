# encoding: utf-8

# text/formatted/parser.rb : Implements a bi-directional parser between a subset
#                            of html and formatted text arrays
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Text
    module Formatted

      class Parser

        def self.to_array(string)
          regex_string = "\n|<b>|</b>|<i>|</i>|<u>|</u>|<strikethrough>|" +
                         "</strikethrough>|<a[^>]*>|</a>|<color[^>]*>|" +
                         "</color>|<font[^>]*>|</font>|[^<\n]+"
          regex = Regexp.new(regex_string, Regexp::MULTILINE)
          tokens = string.scan(regex)
          self.array_from_tokens(tokens)
        end

        def self.to_string(array)
          prefixes = { :bold => "<b>",
                       :italic => "<i>",
                       :underline => "<u>",
                       :strikethrough => "<strikethrough>" }
          suffixes = { :bold => "</b>",
                       :italic => "</i>",
                       :underline => "</u>",
                       :strikethrough => "</strikethrough>" }
          array.collect do |hash|
            prefix = ""
            suffix = ""
            if hash[:style]
              hash[:style].each do |style|
                prefix = prefix + prefixes[style]
                suffix = suffixes[style] + suffix
              end
            end
            font = hash[:font] ? " name='#{hash[:font]}'" : nil
            size = hash[:size] ? " size='#{hash[:size]}'" : nil
            if font || size
              prefix = prefix + "<font#{font}#{size}>"
              suffix = "</font>"
            end
            string = hash[:text].gsub("&", "&amp;").gsub(">", "&gt;").gsub("<", "&lt;")
            prefix + string + suffix
          end.join("")
        end

        private

        def self.array_from_tokens(tokens)
          array = []
          styles = []
          colors = []
          link = nil
          fonts = []
          sizes = []
          
          while token = tokens.shift
            case token
            when "<b>"
              styles << :bold
            when "<i>"
              styles << :italic
            when "<u>"
              styles << :underline
            when "<strikethrough>"
              styles << :strikethrough
            when "</b>"
              styles.delete(:bold)
            when "</i>"
              styles.delete(:italic)
            when "</u>"
              styles.delete(:underline)
            when "</strikethrough>"
              styles.delete(:strikethrough)
            when "</a>"
              link = nil
            when "</color>"
              colors.pop
            when "</font>"
              fonts.pop
              sizes.pop
            else
              if token =~ /^<a[^>]*>$/
                # link =
              elsif token =~ /^<color[^>]*>$/
                # intend to support rgb="#ffffff" or rgb='#ffffff',
                # r="255" g="255" b="255" or r='255' g='255' b='255',
                # and c="100" m="100" y="100" k="100" or
                # c='100' m='100' y='100' k='100' 
                # color = { :rgb => "#ffffff" }
                # color = { :r => 255, :g => 255, :b => 255 }
                # color = { :c => 100, :m => 100, :y => 100, :k => 100 }
              elsif token =~ /^<font[^>]*>$/
                # font =
                matches = /size="(\d+)"/.match(token) || /size='(\d+)'/.match(token)
                sizes << matches[1].to_i unless matches.nil?
              else
                string = token.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&")
                array << { :text => string,
                           :style => styles.dup,
                           :color => colors.last,
                           :link => link,
                           :font => fonts.last,
                           :size => sizes.last }
              end
            end
          end
          array
        end

      end
    end
  end
end
