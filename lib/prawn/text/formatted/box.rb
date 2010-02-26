# encoding: utf-8

# text/formatted/rectangle.rb : Implements text boxes with formatted text
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
require "prawn/text/formatted/arranger"

module Prawn
  module Text
    module Formatted

      # Draws the requested formatted text into a box. When the text overflows
      # the rectangle shrink to fit or truncate the text. Text boxes are
      # independent of the document y position.
      #
      # == Formatted Text Array
      #
      # Formatted text is comprised of an array of hashes, where each hash
      # defines text and format information. As of the time of writing, the
      # following hash options are supported:
      #
      # <tt>:text</tt>::
      #     the text to format according to the other hash options
      # <tt>:style</tt>::
      #     an array of styles to apply to this text. As of now, :italic and
      #     :bold are supported, with the intention of also supporting
      #     :underline and :strikethrough
      # <tt>:size</tt>::
      #     an integer denoting the font size to apply to this text
      # <tt>:font</tt>::
      #     as yet unsupported
      # <tt>:color</tt>::
      #     as yet unsupported
      # <tt>:link</tt>::
      #     as yet unsupported
      #
      # == Example
      #
      #   formatted_text_box([{ :text => "hello" },
      #                       { :text => "world",
      #                         :size => 24,
      #                         :style => [:bold, :italic] }])
      #
      # == Options
      #
      # Accepts the same options as Text::Box with the below exceptions
      #
      # <tt>:formatted_line_wrap</tt>::
      #     <tt>object</tt>. An object used for custom line wrapping on a case
      #     by case basis. Note that if you want to change wrapping
      #     document-wide, do pdf.default_formatted_line_wrap = MyLineWrap.new.
      #     Your custom object must have a wrap_line method that accepts an
      #     <tt>options</tt> hash and returns the part of that string that can
      #     fit on a single line under the conditions defined by
      #     <tt>options</tt> (see the line wrap specs). If omitted, the Prawn
      #     default line wrap object is used. The options hash passed into the
      #     wrap_object proc includes the following options: <tt>:width</tt>::
      #     the width available for the current line of text
      #     <tt>:document</tt>:: the pdf object
      #     <tt>:kerning</tt>:: boolean
      #     <tt>:arranger</tt>:: a Formatted::Arranger object
      #
      #     The line wrap object should have a <tt>width</tt> method that
      #     returns the width of the last line printed and a
      #     <tt>space_count</tt> method that returns the number of spaces in
      #     the last line
      # <tt>:overflow</tt>::
      #     does not accept :ellipses
      #
      # == Returns
      #
      # Returns a formatted text array representing any text that did not print
      # under the current settings.
      #
      # == Exceptions
      #
      # Raises "Bad font family" if no font family is defined for the current font
      #
      # Raises <tt>Prawn::Errrors::CannotFit</tt> if not wide enough to print
      # any text
      #
      # Raises <tt>NotImplementedError</tt> if <tt>:ellipses</tt> <tt>overflow</tt>
      # option included
      #
      def formatted_text_box(array, options)
        Text::Formatted::Box.new(array, options.merge(:document => self)).render
      end

      # Generally, one would use the Prawn::Text::Formatted#formatted_text_box
      # convenience method. However, using Text::Formatted::Box.new in
      # conjunction with #render(:dry_run => true) enables one to do look-ahead
      # calculations prior to placing text on the page, or to determine how much
      # vertical space was consumed by the printed text
      #
      class Box < Prawn::Text::Box
        def initialize(array, options={})
          super(array, options)
          @line_wrap     = options[:formatted_line_wrap] ||
                             @document.default_formatted_line_wrap
          @arranger = Prawn::Text::Formatted::Arranger.new(@document)
          if @overflow == :ellipses
            raise NotImplementedError, "ellipses overflow unavailable with" +
              "formatted box"
          end
        end

        # The height actually used during the previous <tt>render</tt>
        # 
        def height
          return 0 if @baseline_y.nil? || @descender.nil?
          @baseline_y.abs + @line_height - @ascender
        end

        # See the developer documentation for Text::Box#_render
        #
        def _render(array) # :nodoc:
          initialize_inner_render(array)

          move_baseline = true
          while @arranger.unfinished?
            printed_fragments = []

            line_to_print = @line_wrap.wrap_line(:document => @document,
                                                 :kerning => @kerning,
                                                 :width => @width,
                                                 :arranger => @arranger)

            move_baseline = false
            break unless enough_height_for_this_line?
            move_baseline_down

            accumulated_width = 0
            justification_computation if @align == :justify
            while fragment = @arranger.retrieve_string
              if fragment == "\n"
                printed_fragments << "\n" if @printed_lines.last == ""
                break
              end
              printed_fragments << fragment
              draw_fragment(fragment, accumulated_width)
              accumulated_width += @arranger.last_retrieved_width
              if @align == :justify
                accumulated_width += @word_spacing * fragment.count(" ")
              end
            end
            @printed_lines << printed_fragments.join("")
            break if @single_line
            move_baseline = true unless @arranger.finished?
          end
          move_baseline_down if move_baseline
          @text = @printed_lines.join("\n")

          @arranger.unconsumed
        end

        private

        def original_text
          @original_array.collect { |hash| hash.dup }
        end

        def original_text=(array)
          @original_array = array
        end

        def normalize_encoding
          array = original_text
          array.each do |hash|
            hash[:text] = @document.font.normalize_encoding(hash[:text])
          end
          array
        end

        def enough_height_for_this_line?
          @line_height = @arranger.max_line_height
          @descender   = @arranger.max_descender
          @ascender    = @arranger.max_ascender
          required_height = @baseline_y == 0 ? @line_height : @line_height + @descender
          if @baseline_y.abs + required_height > @height
            # no room for the full height of this line
            @arranger.repack_unretrieved
            false
          else
            true
          end
        end

        def initialize_inner_render(array)
          @text = nil
          @arranger.format_array = array

          # these values will depend on the maximum value within a given line
          @line_height = 0
          @descender   = 0
          @ascender    = 0
          @baseline_y  = 0

          @printed_lines = []
        end

        def draw_fragment(fragment, accumulated_width)
          @arranger.apply_font_settings(@arranger.retrieved_format_state) do
            print_fragment(fragment, accumulated_width)
          end
        end

        def move_baseline_down
          if @baseline_y == 0
            @baseline_y  = -@ascender
          else
            @baseline_y -= (@line_height + @leading)
          end
        end

        def print_fragment(fragment, accumulated_width)
          case(@align)
          when :left, :justify
            x = @at[0]
          when :center
            x = @at[0] + @width * 0.5 - @line_wrap.width * 0.5
          when :right
            x = @at[0] + @width - @line_wrap.width
          end

          x += accumulated_width

          y = @at[1] + @baseline_y

          if @inked && @align == :justify
            @document.word_spacing(@word_spacing) {
              @document.draw_text!(fragment, :at => [x, y],
                                   :kerning => @kerning)
            }
          elsif @inked
            @document.draw_text!(fragment, :at => [x, y],
                                 :kerning => @kerning)
          end
        end
      end

    end
  end
end
