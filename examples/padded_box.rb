$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'

Prawn::Document.generate('padded_box.pdf') do
  stroke_bounds
  padded_box(25) do
    stroke_bounds
    padded_box(50) do
      stroke_bounds
    end
  end
end