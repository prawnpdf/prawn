# encoding: utf-8
#
# soft_mask.rb : Implements soft-masking
#
# Copyright September 2012, Alexander Mankuta. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn

  # The Prawn::SoftMask module is used to create arbitrary transparency in
  # document. Using a soft mask allows creaing more visually rich documents.
  #
  # You must group soft mask and graphics it's applied to under
  # save_graphics_state because soft mask is a part of graphic state in PDF.
  #
  # Example:
  #   pdf.save_graphics_state do
  #     pdf.soft_mask do
  #       pdf.fill_color "444444"
  #       pdf.fill_polygon [0, 40], [60, 10], [120, 40], [60, 68]
  #     end
  #     pdf.fill_color '000000'
  #     pdf.fill_rectangle [0, 10], 120, 68
  #   end
  #
  module SoftMask
    def soft_mask(&block)
      min_version(1.4)

      group_attrs = ref!({
        :Type => :Group,
        :S => :Transparency,
        :CS => :DeviceRGB,
        :I => false,
        :K => false
      })

      group = ref!({
        :Type => :XObject,
        :Subtype => :Form,
        :BBox => state.page.dimensions,
        :Group => group_attrs,
      })

      state.page.stamp_stream(group, &block)

      mask = ref!({
        :Type => :Mask,
        :S => :Luminosity,
        :G => group
      })

      g_state = ref!({
        :Type => :ExtGState,
        :SMask => mask,

        :AIS => false,
        :BM => :Normal,
        :OP => false,
        :op => false,
        :OPM => 1,
        :SA => true,
      })

      masks = page.resources[:ExtGState] ||= {}
      id = masks.empty? ? 'GS1' : masks.keys.sort.last.succ
      masks[id] = g_state

      add_content "/#{id} gs"
    end
  end
end
