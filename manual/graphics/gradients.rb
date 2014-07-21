# encoding: utf-8
#
# Note that because of the way PDF renders radial gradients in order to get
# solid fill your start circle must be fully inside your end circle.
# Otherwise you will get triangle fill like illustrated in the example below.

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  stroke_axis
  self.line_width = 10

  fill_gradient [50, 300], [150, 200], 'ff0000', '0000ff'
  fill_rectangle [50, 300], 100, 100

  stroke_gradient [200, 200], [300, 300], '00ffff', 'ffff00'
  stroke_rectangle [200, 300], 100, 100

  fill_gradient [350, 300], [450, 200], 'ff0000', '0000ff'
  stroke_gradient [350, 200], [450, 300], '00ffff', 'ffff00'
  fill_and_stroke_rectangle [350, 300], 100, 100

  fill_gradient [100, 100], 0, [100, 100], 70.71, 'ff0000', '0000ff'
  fill_rectangle [50, 150], 100, 100

  stroke_gradient [250, 100], 45, [250, 100], 70.71, '00ffff', 'ffff00'
  stroke_rectangle [200, 150], 100, 100

  stroke_gradient [400, 100], 45, [400, 100], 70.71, '00ffff', 'ffff00'
  fill_gradient [400, 100], 0, [400, 100], 70.71, 'ff0000', '0000ff'
  fill_and_stroke_rectangle [350, 150], 100, 100

  fill_gradient [500, 300], 15, [500, 50], 0, 'ff0000', '0000ff'
  fill_rectangle [485, 300], 30, 250
end
