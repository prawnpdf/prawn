# encoding: utf-8
#
# There are two drawing primitives on Prawn: fill and stroke.
#
# These are the methods that actually draw stuff on the document. All the other
# drawing shapes like rectangle, circle or line_to define drawing paths.
# These paths need to be either stroked or filled to gain form on the document.
#
# Calling these methods with no block will have effect on the drawing path that
# has been defined prior to the call.
#
# Calling with a block will have effect on the drawing path set within the
# block.
#
# Another option is to call as a method hook. This way the effect will be ran
# right after the drawing path is set.
#
# Here are some examples of possible calls to fill and stroke:
#
require File.expand_path(File.join(File.dirname(__FILE__),
    '..', 'example_helper.rb'))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  # No block
  line [0,250], [100, 150]
  stroke
  
  rectangle [0, 100], 150, 100
  fill
  
  # With block
  stroke { line [200,250], [300, 150] }
  fill   { rectangle [200, 100], 150, 100 }
  
  # Method hook
  stroke_line    [400,250], [500, 150]
  fill_rectangle [400, 100], 150, 100
end
