# frozen_string_literal: true

module Prawn
  # This module is used to create arbitrary transparency in document. Using
  # a soft mask allows creating more visually rich documents.
  module SoftMask
    # @group Stable API

    # Apply soft mask.
    #
    # You must group soft mask and graphics it's applied to under
    # `save_graphics_state` because soft mask is a part of graphic state in PDF.
    #
    # Note that soft mask is applied only to the following content in the
    # graphic state. Anything that comes before `soft_mask` is drawn without
    # mask.
    #
    # Conceptually, soft mask is an alpha channel. Luminosity of the drawing in
    # the soft mask defines the transparency of the drawing the mask is applied
    # to. 0.0 mask luminosity ("black") results in a fully opaque target image and
    # 1.0 mask luminosity ("white") results in a fully transparent target image.
    # Grey values result in some semi-transparent target image.
    #
    # Note: you can use color in mask drawings but it makes harder to reason
    # about the resulting value of alpha channel as it requires an additional
    # luminosity calculation. However, this also allows achieving some advanced
    # artistic effects (e.g. full-color photos in masks to get an effect similar
    # to double exposure).
    #
    # @example
    #   pdf.save_graphics_state do
    #     pdf.soft_mask do
    #       pdf.fill_color "444444"
    #       pdf.fill_polygon [0, 40], [60, 10], [120, 40], [60, 68]
    #     end
    #     pdf.fill_color '000000'
    #     pdf.fill_rectangle [0, 50], 120, 68
    #   end
    #
    # @yield Mask content.
    # @return [void]
    def soft_mask(&block)
      renderer.min_version(1.4)

      group_attrs = ref!(
        Type: :Group,
        S: :Transparency,
        CS: :DeviceRGB,
        I: false,
        K: false,
      )

      group = ref!(
        Type: :XObject,
        Subtype: :Form,
        BBox: state.page.dimensions,
        Group: group_attrs,
      )

      state.page.stamp_stream(group, &block)

      mask = ref!(
        Type: :Mask,
        S: :Luminosity,
        G: group,
      )

      g_state = ref!(
        Type: :ExtGState,
        SMask: mask,

        AIS: false,
        BM: :Normal,
        OP: false,
        op: false,
        OPM: 1,
        SA: true,
      )

      registry_key = {
        bbox: state.page.dimensions,
        mask: [group.stream.filters.normalized, group.stream.filtered_stream],
        page: state.page_count,
      }.hash

      if soft_mask_registry[registry_key]
        renderer.add_content("/#{soft_mask_registry[registry_key]} gs")
      else
        masks = page.resources[:ExtGState] ||= {}
        id = masks.empty? ? 'GS1' : masks.keys.max.succ
        masks[id] = g_state

        soft_mask_registry[registry_key] = id

        renderer.add_content("/#{id} gs")
      end
    end

    private

    def soft_mask_registry
      @soft_mask_registry ||= {}
    end
  end
end
