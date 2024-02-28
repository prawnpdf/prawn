# frozen_string_literal: true

module Prawn
  module Graphics
    # Implements stroke dashing.
    module Dash
      # @group Stable API

      # Get or set stroke dash pattern.
      #
      # @overload dash()
      #   Returns the current dash pattern.
      #
      #   @return [Hash{:dash => Number, Array<Number>, :space => Number, nil, :phase => Number}]
      #
      # @overload dash(length, options ={})
      #   Sets the dash pattern for stroked lines and curves.
      #
      #   Integers or Floats may be used for length and the option values.
      #   Dash units are in PDF points (1/72 inch).
      #
      #   @param length [Number, Array<Number>]
      #     * If `length` is a Number (Integer or Float), it specifies the
      #       length of the dash and of the gap. The length of the gap can be
      #       customized by setting the `:space` option.
      #
      #       Examples:
      #
      #       length = 3
      #       : 3 on, 3 off, 3 on, 3 off, ...
      #
      #       length = 3, :space = 2
      #       : 3 on, 2 off, 3 on, 2 off, ...
      #
      #     * If `length` is an array, it specifies the lengths of alternating
      #       dashes and gaps. The numbers must be non-negative and not all
      #       zero. The `:space` option is ignored in this case.
      #
      #       Examples:
      #
      #       length = [2, 1]
      #       : 2 on, 1 off, 2 on, 1 off, ...
      #
      #       length = [3, 1, 2, 3]
      #       : 3 on, 1 off, 2 on, 3 off, 3 on, 1 off, ...
      #
      #       length = [3, 0, 1]
      #       : 3 on, 0 off, 1 on, 3 off, 0 on, 1 off, ...
      #   @param options [Hash{Symbol => any}]
      #   @option options :space [Number]
      #     The space between the dashes (only used when `length` is not an
      #     array).
      #   @option options :phase [Number] (0)
      #     The distance into the dash pattern at which to start the dash. For
      #     example, a phase of 0 starts at the beginning of the dash; whereas,
      #     if the phase is equal to the length of the dash, then stroking will
      #     begin at the beginning of the space.
      #   @return [void]
      def dash(length = nil, options = {})
        return current_dash_state if length.nil?

        length = Array(length)

        if length.all?(&:zero?)
          raise ArgumentError,
            'Zero length dashes are invalid. Call #undash to disable dashes.'
        elsif length.any?(&:negative?)
          raise ArgumentError,
            'Negative numbers are not allowed for dash lengths.'
        end

        length = length.first if length.length == 1

        self.current_dash_state = {
          dash: length,
          space: length.is_a?(Array) ? nil : options[:space] || length,
          phase: options[:phase] || 0,
        }

        write_stroke_dash
      end

      alias dash= dash

      # Stops dashing, restoring solid stroked lines and curves.
      #
      # @return [void]
      def undash
        self.current_dash_state = undashed_setting
        write_stroke_dash
      end

      # Returns `true` when stroke is dashed, `false` otherwise.
      #
      # @return [Boolean]
      def dashed?
        current_dash_state != undashed_setting
      end

      private

      def write_stroke_dash
        renderer.add_content(dash_setting)
      end

      def undashed_setting
        { dash: nil, space: nil, phase: 0 }
      end

      def current_dash_state=(dash_options)
        graphic_state.dash = dash_options
      end

      def current_dash_state
        graphic_state.dash
      end

      def dash_setting
        graphic_state.dash_setting
      end
    end
  end
end
