# frozen_string_literal: true

module Prawn
  module Graphics
    # Implements stroke join styling.
    module JoinStyle
      # @private
      JOIN_STYLES = { miter: 0, round: 1, bevel: 2 }.freeze

      # @group Stable API

      # Get or set the join style for stroked lines and curves.
      #
      # @overload join_style
      #   Get current join style.
      #
      #   @return [:miter, :round, :bevel]
      #
      # @overload join_style(style)
      #   Set join style.
      #
      #   @note If this method is never called, `:miter` will be used for join
      #     style throughout the document.
      #
      #   @param style [:miter, :round, :bevel]
      #   @return [void]
      #
      #
      def join_style(style = nil)
        return current_join_style || :miter if style.nil?

        self.current_join_style = style

        unless JOIN_STYLES.key?(current_join_style)
          raise Prawn::Errors::InvalidJoinStyle,
            "#{style} is not a recognized join style. Valid styles are " +
              JOIN_STYLES.keys.join(', ')
        end

        write_stroke_join_style
      end

      alias join_style= join_style

      private

      def current_join_style
        graphic_state.join_style
      end

      def current_join_style=(style)
        graphic_state.join_style = style
      end

      def write_stroke_join_style
        renderer.add_content("#{JOIN_STYLES[current_join_style]} j")
      end
    end
  end
end
