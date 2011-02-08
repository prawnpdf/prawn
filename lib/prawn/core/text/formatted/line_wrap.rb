# encoding: utf-8

# core/text/formatted/line_wrap.rb : Implements individual line wrapping of 
#                                    formatted text
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Core
    module Text
      module Formatted #:nodoc:
        
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

          # Work in conjunction with the Prawn::Core::Formatted::Arranger
          # defined in the :arranger option to determine what formatted text
          # will fit within the width defined by the :width option
          #
          def wrap_line(options)
            initialize_line(options)

            while fragment = @arranger.next_string
              @output = ""
              preview = @arranger.preview_next_string

              fragment.lstrip! if @line_output.empty? && fragment != "\n"
              if @line_output.empty? && fragment.empty? && preview == "\n"
                # this line was just whitespace followed by a newline, which is
                # equivalent to just a newline
                @arranger.update_last_string("", "")
                next
              end
              
              if !add_fragment_to_line(fragment)
                fragment_finished(fragment, true)
                break
              end
              
              fragment_finished(fragment, preview == "\n" || preview.nil?)
            end

            @arranger.finalize_line
            @accumulated_width = @arranger.line_width
            @space_count = @arranger.space_count
            @arranger.line
          end

          private

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

          def initialize_line(options)
            @document = options[:document]
            @kerning = options[:kerning]
            @width = options[:width]

            @scan_pattern = scan_pattern
            @word_division_scan_pattern = word_division_scan_pattern

            @accumulated_width = 0
            @line_output = ""

            @arranger = options[:arranger]
            @arranger.initialize_line
          end

          def fragment_finished(fragment, finished_line)
            if fragment == "\n"
              @line_output = "\n" if @line_output.empty?
            else
              update_output_based_on_last_fragment(fragment, finished_line)
              @line_output += @output
            end
          end

          def update_output_based_on_last_fragment(fragment, finished_line)
            remaining_text = fragment.slice(@output.length..fragment.length)
            @output.rstrip! if finished_line
            raise Errors::CannotFit if finished_line && @line_output.empty? &&
              @output.empty? && !fragment.strip.empty?
            @arranger.update_last_string(@output, remaining_text)
          end

          # returns true iff all text was printed without running into the end of
          # the line
          #
          def add_fragment_to_line(fragment)
            return true if fragment == ""
            return false if fragment == "\n"
            previous_segment = nil
            fragment.scan(@scan_pattern).each do |segment|
              @arranger.apply_font_settings do
                segment_width = @document.width_of(segment, :kerning => @kerning)

                if @accumulated_width + segment_width <= @width
                  @accumulated_width += segment_width
                  @output += segment
                else
                  end_of_the_line(segment)
                  return false
                end
              end
              previous_segment = segment
            end
            true
          end

          # If there is more than one word on the line, then clean up the last
          # word on the line; otherwise, wrap by character
          #
          def end_of_the_line(segment)
            if (@line_output + @output) =~ @word_division_scan_pattern
              if segment =~ new_regexp("^#{hyphen}") &&
                  @output !~ new_regexp("[#{break_chars}]$")
                remove_last_output_word
              end
            else
              wrap_by_char(segment)
            end
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
end
