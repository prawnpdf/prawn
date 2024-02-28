# frozen_string_literal: true

module Prawn
  module Text
    module Formatted
      # D data structure for 2-stage processing of lines of formatted text.
      # @private
      class Arranger
        # You're getting this because you're trying to get some information from
        # the arranger before it finished processing text.
        class NotFinalized < StandardError
          # @private
          DEFAULT_MESSAGE = 'Lines must be finalized'

          # @private
          MESSAGE_WITH_METHOD = 'Lines must be finalized before calling #%<method>s'

          def initialize(message = DEFAULT_MESSAGE, method: nil)
            if method && message == DEFAULT_MESSAGE
              super(format(MESSAGE_WITH_METHOD, method: method))
            else
              super(message)
            end
          end
        end

        # You're getting this because a font doesn't have a family name.
        class BadFontFamily < StandardError
          def initialize(message = 'Bad font family')
            super
          end
        end

        attr_reader :max_line_height
        attr_reader :max_descender
        attr_reader :max_ascender
        attr_reader :finalized
        attr_accessor :consumed

        # The following present only for testing purposes
        attr_reader :unconsumed
        attr_reader :fragments
        attr_reader :current_format_state

        def initialize(document, options = {})
          @document = document
          @fragments = []
          @unconsumed = []
          @kerning = options[:kerning]
        end

        # Number of spaces in the text.
        #
        # @return [Integer]
        # @raise [NotFinalized]
        def space_count
          unless finalized
            raise NotFinalized.new(method: 'space_count')
          end

          @fragments.reduce(0) do |sum, fragment|
            sum + fragment.space_count
          end
        end

        # Line width.
        #
        # @return [Number]
        # @raise [NotFinalized]
        def line_width
          unless finalized
            raise raise NotFinalized.new(method: 'line_width')
          end

          @fragments.reduce(0) do |sum, fragment|
            sum + fragment.width
          end
        end

        # Line text.
        #
        # @return [String]
        # @raise [NotFinalized]
        def line
          unless finalized
            raise NotFinalized.new(method: 'line')
          end

          @fragments.map { |fragment|
            begin
              fragment.text.dup.encode(::Encoding::UTF_8)
            rescue ::Encoding::InvalidByteSequenceError, ::Encoding::UndefinedConversionError
              fragment.text.dup.force_encoding(::Encoding::UTF_8)
            end
          }.join
        end

        # Finish laying out current line.
        #
        # @return [void]
        def finalize_line
          @finalized = true

          omit_trailing_whitespace_from_line_width
          @fragments = []
          @consumed.each do |hash|
            text = hash[:text]
            format_state = hash.dup
            format_state.delete(:text)
            fragment = Prawn::Text::Formatted::Fragment.new(
              text,
              format_state,
              @document,
            )
            @fragments << fragment
            self.fragment_measurements = fragment
            self.line_measurement_maximums = fragment
          end
        end

        # Set new fragment array.
        #
        # @param array [Array<Hash>]
        # @return [void]
        def format_array=(array)
          initialize_line
          @unconsumed = []
          array.each do |hash|
            hash[:text].scan(/[^\n]+|\n/) do |line|
              @unconsumed << hash.merge(text: line)
            end
          end
        end

        # Prepare for new line layout.
        #
        # @return [void]
        def initialize_line
          @finalized = false
          @max_line_height = 0
          @max_descender = 0
          @max_ascender = 0

          @consumed = []
          @fragments = []
        end

        # Were all fragments processed?
        #
        # @return [Boolean]
        def finished?
          @unconsumed.empty?
        end

        # Get the next unprocessed string.
        #
        # @return [String, nil]
        # @raise [NotFinalized]
        def next_string
          if finalized
            raise NotFinalized.new(method: 'next_string')
          end

          next_unconsumed_hash = @unconsumed.shift

          if next_unconsumed_hash
            @consumed << next_unconsumed_hash.dup
            @current_format_state = next_unconsumed_hash.dup
            @current_format_state.delete(:text)

            next_unconsumed_hash[:text]
          end
        end

        # Get the next unprocessed string keeping it in the queue.
        #
        # @return [String, nil]
        def preview_next_string
          next_unconsumed_hash = @unconsumed.first

          if next_unconsumed_hash
            next_unconsumed_hash[:text]
          end
        end

        # Apply color and font settings.
        #
        # @param fragment [Prawn::Text::Formatted::Fragment]
        # @yield
        # @return [void]
        def apply_color_and_font_settings(fragment, &block)
          if fragment.color
            original_fill_color = @document.fill_color
            original_stroke_color = @document.stroke_color
            @document.fill_color(*fragment.color)
            @document.stroke_color(*fragment.color)
            apply_font_settings(fragment, &block)
            @document.stroke_color = original_stroke_color
            @document.fill_color = original_fill_color
          else
            apply_font_settings(fragment, &block)
          end
        end

        # Apply font settings.
        #
        # @param fragment [Prawn::Text::Formatted::Fragment]
        # @yield
        # @return [void]
        def apply_font_settings(fragment = nil, &block)
          if fragment.nil?
            font = current_format_state[:font]
            size = current_format_state[:size]
            character_spacing = current_format_state[:character_spacing] ||
              @document.character_spacing
            styles = current_format_state[:styles]
          else
            font = fragment.font
            size = fragment.size
            character_spacing = fragment.character_spacing
            styles = fragment.styles
          end
          font_style = font_style(styles)

          @document.character_spacing(character_spacing) do
            if font || font_style != :normal
              raise BadFontFamily unless @document.font.family

              @document.font(
                font || @document.font.family, style: font_style,
              ) do
                apply_font_size(size, styles, &block)
              end
            else
              apply_font_size(size, styles, &block)
            end
          end
        end

        # Update last fragment's text.
        #
        # @param printed [String]
        # @param unprinted [String]
        # @param normalized_soft_hyphen [Boolean]
        # @return [void]
        def update_last_string(printed, unprinted, normalized_soft_hyphen = nil)
          return if printed.nil?

          if printed.empty?
            @consumed.pop
          else
            @consumed.last[:text] = printed
            if normalized_soft_hyphen
              @consumed.last[:normalized_soft_hyphen] = normalized_soft_hyphen
            end
          end

          unless unprinted.empty?
            @unconsumed.unshift(@current_format_state.merge(text: unprinted))
          end

          load_previous_format_state if printed.empty?
        end

        # Get the next fragment.
        #
        # @return [Prawn::Text::Formatted::Fragment]
        # @raise [NotFinalized]
        def retrieve_fragment
          unless finalized
            raise NotFinalized, 'Lines must be finalized before fragments can be retrieved'
          end

          @fragments.shift
        end

        # Repack remaining fragments.
        #
        # @return [void]
        def repack_unretrieved
          new_unconsumed = []
          # rubocop: disable Lint/AssignmentInCondition
          while fragment = retrieve_fragment
            # rubocop: enable Lint/AssignmentInCondition
            fragment.include_trailing_white_space!
            new_unconsumed << fragment.format_state.merge(text: fragment.text)
          end
          @unconsumed = new_unconsumed.concat(@unconsumed)
        end

        # Get font variant from fragment styles.
        #
        # @param styles [Array<Symbol>]
        # @return [Symbol]
        def font_style(styles)
          styles = Array(styles)
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

        private

        def load_previous_format_state
          if @consumed.empty?
            @current_format_state = {}
          else
            hash = @consumed.last
            @current_format_state = hash.dup
            @current_format_state.delete(:text)
          end
        end

        def apply_font_size(size, styles, &block)
          if subscript?(styles) || superscript?(styles)
            relative_size = 0.583
            size =
              if size.nil?
                @document.font_size * relative_size
              else
                size * relative_size
              end
          end
          if size.nil?
            yield
          else
            @document.font_size(size, &block)
          end
        end

        def subscript?(styles)
          if styles.nil? then false
          else
            styles.include?(:subscript)
          end
        end

        def superscript?(styles)
          if styles.nil? then false
          else
            styles.include?(:superscript)
          end
        end

        def omit_trailing_whitespace_from_line_width
          @consumed.reverse_each do |hash|
            if hash[:text] == "\n"
              break
            elsif hash[:text].strip.empty? && @consumed.length > 1
              # this entire fragment is trailing white space
              hash[:exclude_trailing_white_space] = true
            else
              # this fragment contains the first non-white space we have
              # encountered since the end of the line
              hash[:exclude_trailing_white_space] = true
              break
            end
          end
        end

        def fragment_measurements=(fragment)
          apply_font_settings(fragment) do
            fragment.width = @document.width_of(
              fragment.text,
              kerning: @kerning,
            )
            fragment.line_height = @document.font.height
            fragment.descender = @document.font.descender
            fragment.ascender = @document.font.ascender
          end
        end

        def line_measurement_maximums=(fragment)
          @max_line_height = [
            defined?(@max_line_height) && @max_line_height,
            fragment.line_height,
          ].compact.max
          @max_descender = [
            defined?(@max_descender) && @max_descender,
            fragment.descender,
          ].compact.max
          @max_ascender = [
            defined?(@max_ascender) && @max_ascender,
            fragment.ascender,
          ].compact.max
        end
      end
    end
  end
end
