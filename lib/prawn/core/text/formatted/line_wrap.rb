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
        
        class LineWrap < Prawn::Core::Text::LineWrap #:nodoc:

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

        end
      end
    end
  end
end
