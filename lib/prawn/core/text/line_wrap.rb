# encoding: utf-8

# core/text/line_wrap.rb : Implements individual line wrapping
#
# Copyright January 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Core
    module Text
      
      class LineWrap #:nodoc:

        # The width of the last wrapped line
        #
        def width
          @accumulated_width || 0
        end

        # The number of spaces in the last wrapped line
        #
        def space_count
          @space_count
        end

        # The number of characters consumed from the last line passed into
        # wrap_line. This may differ from the number of characters in the
        # returned line because trailing white spaces are removed
        #
        def consumed_char_count
          @consumed_char_count
        end

        # The pattern used to determine chunks of text to place on a given line
        #
        def scan_pattern
          pattern = "[^#{break_chars}]+#{soft_hyphen}|" +
                    "[^#{break_chars}]+#{hyphen}+|" +
                    "[^#{break_chars}]+|" +
                    "[#{whitespace}]+|" +
                    "#{hyphen}+[^#{break_chars}]*|" +
                    "#{soft_hyphen}"
          new_regexp(pattern)
        end

        # The pattern used to determine whether any word breaks exist on a
        # current line, which in turn determines whether character level
        # word breaking is needed
        #
        def word_division_scan_pattern
          new_regexp("\\s|[#{hyphen}#{soft_hyphen}]")
        end

        # Take a single line and deterimine what part of it fits within the
        # width defined by the :width option
        #
        def wrap_line(line, options)
          initialize_line(options)

          previous_segment = nil
          line.scan(@scan_pattern).each do |segment|
            segment_width = @document.width_of(segment, :kerning => @kerning)

            if @accumulated_width + segment_width <= @width
              @accumulated_width += segment_width
              @output += segment
            else
              end_of_the_line(segment)
              break
            end
            previous_segment = segment
          end
          raise Errors::CannotFit if @output.empty? && !line.strip.empty?

          finalize_line
          @space_count = @output.count(" ")
          @output
        end

        private

        def initialize_line(options)
          @document = options[:document]
          @kerning = options[:kerning]
          @width = options[:width]

          @scan_pattern = scan_pattern
          @word_division_scan_pattern = word_division_scan_pattern

          @accumulated_width = 0
          @output = ""
        end

        def break_chars
          "#{whitespace}#{soft_hyphen}#{hyphen}"
        end

        def whitespace
          " \\t"
        end

        def hyphen
          "-"
        end

        def soft_hyphen
          @document.font.normalize_encoding("­")
        end

        # If there is more than one word on the line, then clean up the last
        # word on the line; otherwise, wrap by character
        #
        def end_of_the_line(segment)
          if @output =~ @word_division_scan_pattern
            if segment =~ new_regexp("^#{hyphen}") &&
                @output !~ new_regexp("[#{break_chars}]$")
              remove_last_output_word
            end
          else
            wrap_by_char(segment)
            # since when adding characters individually, kerning has no effect,
            # recompute width of the output after adding characters
            # IMPORTANT: leave this computation here, rather than moving it into
            # append_char because append_char is more general than
            # end_of_the_line, so while end_of_the_line is likely to be
            # overridden, wrap_by_char may not be, and we don't want to
            # recompute line width except where necessary (for example, see
            # Prawn::Core::Text::Formatted::LineWrap)
            @accumulated_width = compute_output_width
          end
        end

        def remove_last_output_word
          segments = []
          regexp = new_regexp("[^#{break_chars}]+|[#{break_chars}]+")
          @output.scan(regexp).each { |segment| segments << segment }
          segments.pop
          @output = segments.join("")
        end

        def finalize_line
          @consumed_char_count = @output.length

          @output = @output[0..-2].gsub(soft_hyphen, "") + @output[-1..-1]

          strip_trailing_whitespace
        end

        def strip_trailing_whitespace
          @accumulated_width = compute_output_width if @output.strip!
        end

        def compute_output_width
          @document.width_of(@output, :kerning => @kerning)
        end

        def wrap_by_char(segment)
          if @document.font.unicode?
            segment.unpack("U*").each do |char_int|
              break unless append_char([char_int].pack("U"))
            end
          else
            segment.each_char do |char|
              break unless append_char(char)
            end
          end
        end

        def append_char(char)
          # kerning doesn't make sense in the context of a single character
          char_width = @document.width_of(char)
          @accumulated_width += char_width

          if @accumulated_width >= @width
            false
          else
            @output << char
            true
          end
        end

        def new_regexp(pattern)
          regexp = ruby_19 {
            Regexp.new(pattern)
          }
          regexp = regexp || ruby_18 {
            lang = @document.font.unicode? ? 'U' : 'N'
            Regexp.new(pattern, 0, lang)
          }
          regexp
        end

      end
    end
  end
end
