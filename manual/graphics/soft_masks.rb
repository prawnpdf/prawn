# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Soft Masks'

  text do
    prose <<~TEXT
      Soft masks are used for more complex alpha channel manipulations. You can
      use arbitrary drawing functions for creation of soft masks. The resulting
      alpha channel is made of greyscale version of the drawing (luminosity
      channel to be precise). So while you can use any combination of colors
      for soft masks it's easier to use greyscales. Black will result in full
      transparency and white will make region fully opaque.

      Soft mask is a part of page graphic state. So if you want to apply soft
      mask only to a part of page you need to enclose drawing instructions in
      <code>save_graphics_state</code> block.
    TEXT
  end

  example do
    save_graphics_state do
      soft_mask do
        0.upto 15 do |i|
          fill_color 0, 0, 0, 100.0 / 16.0 * (15 - i)
          fill_circle [75 + i * 25, 100], 60
        end
      end

      %w[009ddc 963d97 e03a3e f5821f fdb827 61bb46].each_with_index do |color, i|
        fill_color color
        fill_rectangle [0, 60 + i * 20], 600, 20
      end
    end
  end
end
