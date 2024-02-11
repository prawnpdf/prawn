# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Blend Modes'

  text do
    prose <<~TEXT
      Blend modes can be used to change the way two layers (images, graphics,
      text, etc.) are blended together. The <code>blend_mode</code> method
      accepts a single blend mode or an array of blend modes. PDF viewers
      should blend the layers based on the first recognized blend mode.

      Valid blend modes in v1.4 of the PDF spec include <code>:Normal</code>,
      <code>:Multiply</code>, <code>:Screen</code>, <code>:Overlay</code>,
      <code>:Darken</code>, <code>:Lighten</code>, <code>:ColorDodge</code>,
      <code>:ColorBurn</code>, <code>:HardLight</code>,
      <code>:SoftLight</code>, <code>:Difference</code>,
      <code>:Exclusion</code>, <code>:Hue</code>, <code>:Saturation</code>,
      <code>:Color</code>, and <code>:Luminosity</code>.
    TEXT
  end

  example new_page: true do
    # https://commons.wikimedia.org/wiki/File:Blend_modes_2.-bottom-layer.jpg#/media/File:Blend_modes_2.-bottom-layer.jpg
    bottom_layer = "#{Prawn::DATADIR}/images/blend_modes_bottom_layer.jpg"

    # https://commons.wikimedia.org/wiki/File:Blend_modes_1.-top-layer.jpg#/media/File:Blend_modes_1.-top-layer.jpg
    top_layer = "#{Prawn::DATADIR}/images/blend_modes_top_layer.jpg"

    blend_modes = %i[
      Normal Multiply Screen Overlay Darken Lighten ColorDodge
      ColorBurn HardLight SoftLight Difference Exclusion Hue
      Saturation Color Luminosity
    ]
    blend_modes.each_with_index do |blend_mode, index|
      x = 5 + index % 4 * 130
      y = cursor - (index / 4 * 195) - 5

      image bottom_layer, at: [x, y], fit: [120, 120]
      blend_mode(blend_mode) do
        image top_layer, at: [x, y], fit: [120, 120]
      end

      y -= 130

      fill_color '009ddc'
      fill_rectangle [x, y], 75, 25
      blend_mode(blend_mode) do
        fill_color 'fdb827'
        fill_rectangle [x + 50, y], 70, 25
      end

      y -= 30

      fill_color '000000'
      text_box blend_mode.to_s, at: [x, y]
    end
  end
end
