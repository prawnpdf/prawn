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
        # @group Extension API

        PARSER_REGEX = begin
          regex_string = "\n|" \
                         "<b>|</b>|" \
                         "<i>|</i>|" \
                         "<u>|</u>|" \
                         "<strikethrough>|</strikethrough>|" \
                         "<sub>|</sub>|" \
                         "<sup>|</sup>|" \
                         "<link[^>]*>|</link>|" \
                         "<color[^>]*>|</color>|" \
                         "<font[^>]*>|</font>|" \
                         "<strong>|</strong>|" \
                         "<em>|</em>|" \
                         "<a[^>]*>|</a>|" \
                         "[^<\n]+"
          Regexp.new(regex_string, Regexp::MULTILINE)
        end

        def self.format(string, *args)
          tokens = string.gsub(/<br\s*\/?>/, "\n").scan(PARSER_REGEX)
          self.array_from_tokens(tokens)
        end

        def self.to_string(array)
          prefixes = { :bold => "<b>",
                       :italic => "<i>",
                       :underline => "<u>",
                       :strikethrough => "<strikethrough>",
                       :subscript => "<sub>",
                       :superscript => "<sup>" }
          suffixes = { :bold => "</b>",
                       :italic => "</i>",
                       :underline => "</u>",
                       :strikethrough => "</strikethrough>",
                       :subscript => "</sub>",
                       :superscript => "</sup>" }
          array.collect do |hash|
            prefix = ""
            suffix = ""
            if hash[:styles]
              hash[:styles].each do |style|
                prefix = prefix + prefixes[style]
                suffix = suffixes[style] + suffix
              end
            end

            font = hash[:font] ? " name='#{hash[:font]}'" : nil
            size = hash[:size] ? " size='#{hash[:size]}'" : nil
            if hash[:character_spacing]
              character_spacing = " character_spacing='#{hash[:character_spacing]}'"
            else
              character_spacing = nil
            end
            if font || size || character_spacing
              prefix = prefix + "<font#{font}#{size}#{character_spacing}>"
              suffix = "</font>"
            end

            link = hash[:link] ? " href='#{hash[:link]}'" : nil
            anchor = hash[:anchor] ? " anchor='#{hash[:anchor]}'" : nil
            if link || anchor
              prefix = prefix + "<link#{link}#{anchor}>"
              suffix = "</link>"
            end

            if hash[:color]
              if hash[:color].kind_of?(Array)
                prefix = prefix + "<color c='#{hash[:color][0]}'" \
                                        " m='#{hash[:color][1]}'" \
                                        " y='#{hash[:color][2]}'" \
                                        " k='#{hash[:color][3]}'>"
              else
                prefix = prefix + "<color rgb='#{hash[:color]}'>"
              end
              suffix = "</color>"
            end

            string = hash[:text].gsub("&", "&amp;").gsub(">", "&gt;").gsub("<", "&lt;")
            prefix + string + suffix
          end.join
        end

        def self.array_paragraphs(array) #:nodoc:
          paragraphs = []
          paragraph = []
          previous_string = "\n"
          scan_pattern = /[^\n]+|\n/
          array.each do |hash|
            hash[:text].scan(scan_pattern).each do |string|
              if string == "\n"
                paragraph << hash.dup.merge(:text => "\n") if previous_string == "\n"
                paragraphs << paragraph unless paragraph.empty?
                paragraph = []
              else
                paragraph << hash.dup.merge(:text => string)
              end
              previous_string = string
            end
          end
          paragraphs << paragraph unless paragraph.empty?
          paragraphs
        end

        def self.array_from_tokens(tokens)
          array = []
          styles = []
          colors = []
          link = nil
          anchor = nil
          local = nil
          fonts = []
          sizes = []
          character_spacings = []

          while token = tokens.shift
            case token
            when "<b>", "<strong>"
              styles << :bold
            when "<i>", "<em>"
              styles << :italic
            when "<u>"
              styles << :underline
            when "<strikethrough>"
              styles << :strikethrough
            when "<sub>"
              styles << :subscript
            when "<sup>"
              styles << :superscript
            when "</b>", "</strong>"
              styles.delete(:bold)
            when "</i>", "</em>"
              styles.delete(:italic)
            when "</u>"
              styles.delete(:underline)
            when "</strikethrough>"
              styles.delete(:strikethrough)
            when "</sub>"
              styles.delete(:subscript)
            when "</sup>"
              styles.delete(:superscript)
            when "</link>", "</a>"
              link = nil
              anchor = nil
              local = nil
            when "</color>"
              colors.pop
            when "</font>"
              fonts.pop
              sizes.pop
              character_spacings.pop
            else
              if token =~ /^<link[^>]*>$/ or token =~ /^<a[^>]*>$/
                matches = /href="([^"]*)"/.match(token) || /href='([^']*)'/.match(token)
                link = matches[1] unless matches.nil?

                matches = /anchor="([^"]*)"/.match(token) || /anchor='([^']*)'/.match(token)
                anchor = matches[1] unless matches.nil?

                matches = /local="([^"]*)"/.match(token) || /local='([^']*)'/.match(token)
                local = matches[1] unless matches.nil?
              elsif token =~ /^<color[^>]*>$/
                matches = /rgb="#?([^"]*)"/.match(token) || /rgb='#?([^']*)'/.match(token)
                colors << matches[1] if matches

                matches = /c="#?([^"]*)" +m="#?([^"]*)" +y="#?([^"]*)" +k="#?([^"]*)"/.match(token) ||
                          /c='#?([^']*)' +m='#?([^']*)' +y='#?([^']*)' +k='#?([^']*)'/.match(token)
                colors << [matches[1].to_i, matches[2].to_i, matches[3].to_i, matches[4].to_i] if matches

                # intend to support rgb="#ffffff" or rgb='#ffffff',
                # r="255" g="255" b="255" or r='255' g='255' b='255',
                # and c="100" m="100" y="100" k="100" or
                # c='100' m='100' y='100' k='100'
                # color = { :rgb => "#ffffff" }
                # color = { :r => 255, :g => 255, :b => 255 }
                # color = { :c => 100, :m => 100, :y => 100, :k => 100 }
              elsif token =~ /^<font[^>]*>$/
                matches = /name="([^"]*)"/.match(token) || /name='([^']*)'/.match(token)
                fonts << matches[1] unless matches.nil?

                matches = /size="([^"]*)"/.match(token) || /size='([^']*)'/.match(token)
                sizes << matches[1].to_f unless matches.nil?

                matches = /character_spacing="([^"]*)"/.match(token) || /character_spacing='([^']*)'/.match(token)
                character_spacings << matches[1].to_f unless matches.nil?
              else
                string = token.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&")
                array << { :text => string,
                           :styles => styles.dup,
                           :color => colors.last,
                           :local => local,
                           :link => link,
                           :anchor => anchor,
                           :font => fonts.last,
                           :size => sizes.last,
                           :character_spacing => character_spacings.last }
              end
            end
          end
          array
        end
      end
    end
  end
end
