# frozen_string_literal: true

module Prawn
  module Text
    module Formatted
      # Prawn::Text::Formatted::Fragment is a state store for a formatted text
      # fragment. It does not render anything.
      #
      # @private
      class Fragment
        attr_reader :format_state
        attr_reader :text
        attr_writer :width
        attr_accessor :line_height
        attr_accessor :descender
        attr_accessor :ascender
        attr_accessor :word_spacing
        attr_accessor :left
        attr_accessor :baseline

        # @param text [String]
        # @param format_state [Hash{Symbol => any}]
        # @param document [Prawn::Documnt]
        def initialize(text, format_state, document)
          @format_state = format_state
          @document = document
          @word_spacing = 0

          # keep the original value of "text", so we can reinitialize @text if
          # formatting parameters like text direction are changed
          @original_text = text
          @text = process_text(@original_text)
        end

        # Width of fragment.
        #
        # @return [Number]
        def width
          if @word_spacing.zero? then @width
          else
            @width + (@word_spacing * space_count)
          end
        end

        # Height of fragment.
        #
        # @return [Number]
        def height
          top - bottom
        end

        # Is this a subscript fragment?
        #
        # @return [Boolean]
        def subscript?
          styles.include?(:subscript)
        end

        # Is this a superscript fragment?
        #
        # @return [Boolean]
        def superscript?
          styles.include?(:superscript)
        end

        # Vertical offset of the fragment.
        #
        # @return [Number]
        def y_offset
          if subscript? then -descender
          elsif superscript? then 0.85 * ascender
          else
            0
          end
        end

        # Fragment bounding box, relative to the containing bounding box.
        #
        # @return [Array(Number, Number, Number, Number)]
        def bounding_box
          [left, bottom, right, top]
        end

        # Fragment bounding box, relative to the containing page.
        #
        # @return [Array(Number, Number, Number, Number)]
        def absolute_bounding_box
          box = bounding_box
          box[0] += @document.bounds.absolute_left
          box[2] += @document.bounds.absolute_left
          box[1] += @document.bounds.absolute_bottom
          box[3] += @document.bounds.absolute_bottom
          box
        end

        # Underline endpoints.
        #
        # @return [Array(Array(Number, Number), Array(Number, Number))]
        def underline_points
          y = baseline - 1.25
          [[left, y], [right, y]]
        end

        # Strikethrough endpoints.
        #
        # @return [Array(Array(Number, Number), Array(Number, Number))]
        def strikethrough_points
          y = baseline + (ascender * 0.3)
          [[left, y], [right, y]]
        end

        # Fragment font styles.
        #
        # @return [Array<Symbol>]
        def styles
          @format_state[:styles] || []
        end

        # Fragment link.
        #
        # @return [String, nil]
        def link
          @format_state[:link]
        end

        # Anchor.
        #
        # @return [PDF::Core::Reference, Array, Hash]
        def anchor
          @format_state[:anchor]
        end

        # Local destination.
        #
        # @return [String]
        def local
          @format_state[:local]
        end

        # Fragment color.
        #
        # @return [Color]
        def color
          @format_state[:color]
        end

        # Fragment font name.
        #
        # @return [String]
        def font
          @format_state[:font]
        end

        # Font size.
        #
        # @return [Number]
        def size
          @format_state[:size]
        end

        # Character spacing.
        #
        # @return [Number]
        def character_spacing
          @format_state[:character_spacing] ||
            @document.character_spacing
        end

        # Text direction.
        #
        # @return [:ltr, :rtl]
        def direction
          @format_state[:direction]
        end

        # Set default text direction.
        #
        # @param direction [:ltr, :rtl]
        # @return [void]
        def default_direction=(direction)
          unless @format_state[:direction]
            @format_state[:direction] = direction
            @text = process_text(@original_text)
          end
        end

        # Keep trailing spaces.
        #
        # @return [void]
        def include_trailing_white_space!
          @format_state.delete(:exclude_trailing_white_space)
          @text = process_text(@original_text)
        end

        # Number of spaces in the text.
        #
        # @return [Integer]
        def space_count
          @text.count(' ')
        end

        # Callbacks.
        #
        # @return [Array]
        def callback_objects
          callback = @format_state[:callback]
          if callback.nil?
            []
          elsif callback.is_a?(Array)
            callback
          else
            [callback]
          end
        end

        # Horizontal coordinate of the right side of the fragment.
        #
        # @return [Number]
        def right
          left + width
        end

        # Vertical coordinate of the top side of the fragment.
        #
        # @return [Number]
        def top
          baseline + ascender
        end

        # Vertical coordinate of the bottom side of the fragment.
        #
        # @return [Number]
        def bottom
          baseline - descender
        end

        # Coordinates of the top left corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def top_left
          [left, top]
        end

        # Coordinates of the top right corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def top_right
          [right, top]
        end

        # Coordinates of the bottom right corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def bottom_right
          [right, bottom]
        end

        # Coordinates of the bottom left corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def bottom_left
          [left, bottom]
        end

        # Absolute horizontal coordinate of the left side of the fragment.
        #
        # @return [Number]
        def absolute_left
          absolute_bounding_box[0]
        end

        # Absolute horizontal coordinate of the right side of the fragment.
        #
        # @return [Number]
        def absolute_right
          absolute_bounding_box[2]
        end

        # Absolute vertical coordinate of the top side of the fragment.
        #
        # @return [Number]
        def absolute_top
          absolute_bounding_box[3]
        end

        # Absolute vertical coordinate of the bottom side of the fragment.
        #
        # @return [Number]
        def absolute_bottom
          absolute_bounding_box[1]
        end

        # Absolute coordinates of the top left corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def absolute_top_left
          [absolute_left, absolute_top]
        end

        # Absolute coordinates of the top right corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def absolute_top_right
          [absolute_right, absolute_top]
        end

        # Absolute coordinates of the bottom left corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def absolute_bottom_left
          [absolute_left, absolute_bottom]
        end

        # Absolute coordinates of the bottom right corner of the fragment.
        #
        # @return [Array(Number, Number)]
        def absolute_bottom_right
          [absolute_right, absolute_bottom]
        end

        private

        def process_text(text)
          string = strip_zero_width_spaces(text)

          if exclude_trailing_white_space?
            string = string.rstrip

            if soft_hyphens_need_processing?(string)
              string = process_soft_hyphens(string[0..-2]) + string[-1..]
            end
          elsif soft_hyphens_need_processing?(string)
            string = process_soft_hyphens(string)
          end

          if direction == :rtl
            string.reverse
          else
            string
          end
        end

        def exclude_trailing_white_space?
          @format_state[:exclude_trailing_white_space]
        end

        def soft_hyphens_need_processing?(string)
          !string.empty? && normalized_soft_hyphen
        end

        def normalized_soft_hyphen
          @format_state[:normalized_soft_hyphen]
        end

        def process_soft_hyphens(string)
          if string.encoding != normalized_soft_hyphen.encoding
            string.force_encoding(normalized_soft_hyphen.encoding)
          end

          string.gsub(normalized_soft_hyphen, '')
        end

        def strip_zero_width_spaces(string)
          if string.encoding == ::Encoding::UTF_8
            string.gsub(Prawn::Text::ZWSP, '')
          else
            string
          end
        end
      end
    end
  end
end
