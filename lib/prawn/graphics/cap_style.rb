# frozen_string_literal: true

module Prawn
  module Graphics
    # Implements stroke cap styling
    module CapStyle
      # @group Stable API

      # @private
      CAP_STYLES = { butt: 0, round: 1, projecting_square: 2 }.freeze

      # Sets the cap style for stroked lines and curves.
      #
      # @overload cap_style(style)
      #   @param style [:butt, :round, :projecting_square] (:butt)
      #   @return [void]
      # @overload cap_style()
      #   @return [Symbol]
      def cap_style(style = nil)
        return current_cap_style || :butt if style.nil?

        self.current_cap_style = style

        write_stroke_cap_style
      end

      alias cap_style= cap_style

      private

      def current_cap_style
        graphic_state.cap_style
      end

      def current_cap_style=(style)
        graphic_state.cap_style = style
      end

      def write_stroke_cap_style
        renderer.add_content("#{CAP_STYLES[current_cap_style]} J")
      end
    end
  end
end
