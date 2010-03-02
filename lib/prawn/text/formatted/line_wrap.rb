# encoding: utf-8

# text/formatted/line_wrap.rb : Implements individual line wrapping of formatted
#                               text
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Text
    module Formatted
      
      class LineWrap < Prawn::Text::LineWrap

        def wrap_line(options)
          @document = options[:document]
          @kerning = options[:kerning]
          @width = options[:width]
          @arranger = options[:arranger]
          @accumulated_width = 0
          @scan_pattern = @document.font.unicode? ? /\S+|\s+/ : /\S+|\s+/n
          @space_scan_pattern = @document.font.unicode? ? /\s/ : /\s/n

          _wrap_line

          @arranger.finalize_line
          @accumulated_width = @arranger.line_width
          @space_count = @arranger.space_count
          @arranger.line
        end

        private

        def _wrap_line
          @arranger.initialize_line
          @line_output = ""
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
          fragment.scan(@scan_pattern).each do |segment|
            @arranger.apply_font_settings do
              segment_width = @document.width_of(segment, :kerning => @kerning)

              if @accumulated_width + segment_width <= @width
                @accumulated_width += segment_width
                @output += segment
              else
                # if the line contains white space, don't split the
                # final word that doesn't fit, just return what fits nicely
                unless (@line_output + @output) =~ @space_scan_pattern
                  wrap_by_char(segment)
                end
                return false
              end
            end
          end
          true
        end

      end
    end
  end
end
