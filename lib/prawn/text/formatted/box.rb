# encoding: utf-8

# text/rectangle.rb : Implements text boxes
#
# Copyright November 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Text
    module Formatted

      # Draws the requested text into a box. When the text overflows
      # the rectangle, you can display ellipses, shrink to fit, or
      # truncate the text. Text boxes are independent of the document
      # y position.
      #
      # <tt>:formatted_line_wrap</tt>:: <tt>object</tt>. An object used for
      #                       custom line wrapping on a case by case basis. Note
      #                       that if you want to change wrapping document-wide,
      #                       do pdf.default_unformatted_line_wrap =
      #                       MyLineWrap.new.  Your custom object must have a
      #                       wrap_line method that accepts an <tt>options</tt>
      #                       hash and returns the string from that single line
      #                       that can fit on the line under the conditions
      #                       defined by <tt>options</tt>. If omitted, the line
      #                       wrap object is used. The options hash passed into
      #                       the wrap_object proc includes the following
      #                       options:
      #
      #                       <tt>:width</tt>:: the width available for the
      #                                         current line of text
      #                       <tt>:document</tt>:: the pdf object
      #                       <tt>:kerning</tt>:: boolean
      #                       <tt>:inline_format</tt>:: an InlineFormatter
      #                       object
      #
      #                        The line wrap object should have a <tt>width</tt>
      #                        method that returns the width of the last line
      #                        printed
      #
      def formatted_text_box(array, options)
        Text::Formatted::Box.new(array, options.merge(:document => self)).render
      end

      # Generally, one would use the formatted_text_box convenience method. However, using
      # Text::Formatted::Box.new in conjunction with render() enables one to do look-ahead
      # calculations prior to placing text on the page, or to determine how much
      # vertical space was consumed by the printed text
      #
      class Box < Prawn::Text::Box
        def initialize(array, options={})
          @inline_format = InlineFormatter.new
          super(array, options)
          @line_wrap     = options[:formatted_line_wrap] ||
                             @document.default_formatted_line_wrap
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

        def _render(array)
          initialize_inner_render(array)

          move_baseline = true
          while @inline_format.unfinished?
            printed_fragments = []

            @line_wrap.wrap_line(:document => @document,
                                 :kerning => @kerning,
                                 :width => @width,
                                 :inline_format => @inline_format)

            move_baseline = false
            break unless enough_space_for_this_line?
            move_baseline_down

            accumulated_width = 0
            while fragment = @inline_format.retrieve_string
              if fragment == "\n"
                printed_fragments << "\n" if @printed_lines.last == ""
                break
              end
              printed_fragments << fragment
              draw_fragment(fragment, accumulated_width)
              accumulated_width += @inline_format.last_retrieved_width
            end
            @printed_lines << printed_fragments.join("")
            break if @single_line
            move_baseline = true unless @inline_format.finished?
          end
          move_baseline_down if move_baseline
          @text = @printed_lines.join("\n")

          @inline_format.unconsumed
        end

        def enough_space_for_this_line?
          @line_height = @inline_format.max_line_height
          @descender   = @inline_format.max_descender
          @ascender    = @inline_format.max_ascender
          required_space = @baseline_y == 0 ? @line_height : @line_height + @descender
          if @baseline_y.abs + required_space > @height
            # no room for the full height of this line
            @inline_format.repack_unretrieved
            false
          else
            true
          end
        end

        def initialize_inner_render(array)
          @text = nil
          @inline_format.format_array = array

          # these values will depend on the maximum value within a given line
          @line_height = 0
          @descender   = 0
          @ascender    = 0
          @baseline_y  = 0

          @printed_lines = []
        end

        def draw_fragment(fragment, accumulated_width)
          raise "Bad font family" unless @document.font.family
          @document.font(@document.font.family,
                         :style => @inline_format.last_retrieved_font_style) do
            @document.font_size(@inline_format.last_retrieved_font_size ||
                                @document.font_size) do
              print_fragment(fragment, accumulated_width, @line_wrap.width)
            end
          end
        end

        def move_baseline_down
          if @baseline_y == 0
            @baseline_y  = -@ascender
          else
            @baseline_y -= (@line_height + @leading)
          end
        end

        def print_fragment(fragment, accumulated_width, line_width)
          case(@align)
          when :left
            x = @at[0]
          when :center
            x = @at[0] + @width * 0.5 - line_width * 0.5
          when :right
            x = @at[0] + @width - line_width
          end

          x += accumulated_width

          y = @at[1] + @baseline_y

          if @inked
            @document.draw_text!(fragment, :at => [x, y],
                                 :kerning => @kerning)
          end
        end

      end


      class InlineFormatter
        attr_reader :consumed
        attr_reader :unconsumed
        attr_reader :current_format_state
        attr_reader :max_line_height
        attr_reader :max_descender
        attr_reader :max_ascender
        attr_reader :last_retrieved_width

        def initialize
          @retrieved_format_state = []
          @current_format_state = {}
          @consumed = []
        end

        def format_array=(array)
          initialize_line
          @unconsumed = []
          array.each do |hash|
            hash[:text].scan(/[^\n]+|\n/) do |line|
              @unconsumed << hash.merge(:text => line)
            end
          end
        end

        def initialize_line
          @max_line_height = 0
          @max_descender = 0
          @max_ascender = 0
        end

        def finished?
          @unconsumed.length == 0
        end

        def unfinished?
          @unconsumed.length > 0
        end

        def next_string
          hash = @unconsumed.shift
          if hash.nil?
            nil
          else
            @consumed << hash.dup
            @current_format_state = hash.dup
            @current_format_state.delete(:text)
            hash[:text]
          end
        end

        def preview_next_string
          hash = @unconsumed.first
          if hash.nil?
            nil
          else
            hash[:text]
          end
        end

        def set_last_string_size_data(options)
          @consumed.last[:width] = options[:width]
          @max_line_height = [@max_line_height, options[:line_height]].max
          @max_descender = [@max_descender, options[:descender]].max
          @max_ascender = [@max_ascender, options[:ascender]].max
        end

        def update_last_string(printed, unprinted=nil)
          return if printed.nil?
          @consumed.last[:text] = printed

          unless unprinted.empty? # || unprinted =~ /^ +$/
            @unconsumed.unshift(@current_format_state.merge(:text => unprinted))
          end
        end

        def retrieve_string
          hash = @consumed.shift
          if hash.nil?
            @retrieved_format_state = nil
            @last_retrieved_width = 0
            nil
          else
            @retrieved_format_state = hash.dup
            @retrieved_format_state.delete(:text)
            @last_retrieved_width = hash[:width]
            hash[:text]
          end
        end

        def repack_unretrieved
          new_unconsumed = []
          while string = retrieve_string
            new_unconsumed << @retrieved_format_state.merge(:text => string)
          end
          @unconsumed = new_unconsumed.concat(@unconsumed)
        end

        def last_retrieved_font_style
          styles = @retrieved_format_state[:style]
          return :normal if styles.nil?
          if styles.include?(:bold) && styles.include?(:italic)
            :bold_italic
          elsif styles.include?(:bold)
            :bold
          elsif styles.include?(:italic)
            :italic
          else
            :normal
          end
        end

        def current_font_style
          styles = @current_format_state[:style]
          return :normal if styles.nil?
          if styles.include?(:bold) && styles.include?(:italic)
            :bold_italic
          elsif styles.include?(:bold)
            :bold
          elsif styles.include?(:italic)
            :italic
          else
            :normal
          end
        end

        def last_retrieved_font_size
          @retrieved_format_state[:size]
        end

        def current_font_size
          @current_format_state[:size]
        end

      end

    end
  end
end
