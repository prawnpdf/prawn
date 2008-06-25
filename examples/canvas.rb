$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("canvas.pdf") do
  canvas do
    text "This text should appear at the absolute top left"
    # stroke a line to show that the relative coordinates are the same as absolute
    stroke_line [bounds.left,bounds.bottom], [bounds.right,bounds.top]
  end
end
