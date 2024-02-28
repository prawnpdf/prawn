# frozen_string_literal: true

module Prawn
  module Graphics
    # The {Prawn::BlendMode} module is used to change the way two graphic
    # objects are blended together.
    module BlendMode
      # @group Stable API

      # Set blend mode. If a block is passed blend mode is restored afterwards.
      #
      # Passing an array of blend modes is allowed. PDF viewers should blend
      # layers based on the first recognized blend mode.
      #
      # Valid blend modes since PDF 1.4 include `:Normal`, `:Multiply`, `:Screen`,
      # `:Overlay`, `:Darken`, `:Lighten`, `:ColorDodge`, `:ColorBurn`,
      # `:HardLight`, `:SoftLight`, `:Difference`, `:Exclusion`, `:Hue`,
      # `:Saturation`, `:Color`, and `:Luminosity`.
      #
      # @example
      #   pdf.fill_color('0000ff')
      #   pdf.fill_rectangle([x, y + 25], 50, 50)
      #   pdf.blend_mode(:Multiply) do
      #     pdf.fill_color('ff0000')
      #     pdf.fill_circle([x, y], 25)
      #   end
      #
      # @param blend_mode [Symbol, Array<Symbol>]
      # @yield
      # @return [void]
      def blend_mode(blend_mode = :Normal)
        renderer.min_version(1.4)

        save_graphics_state if block_given?
        renderer.add_content("/#{blend_mode_dictionary_name(blend_mode)} gs")
        if block_given?
          yield
          restore_graphics_state
        end
      end

      private

      def blend_mode_dictionary_registry
        @blend_mode_dictionary_registry ||= {}
      end

      def blend_mode_dictionary_name(blend_mode)
        key = Array(blend_mode).join('')
        dictionary_name = "BM#{key}"

        dictionary = blend_mode_dictionary_registry[dictionary_name] ||= ref!(
          Type: :ExtGState,
          BM: blend_mode,
        )

        page.ext_gstates[dictionary_name] = dictionary
        dictionary_name
      end
    end
  end
end
