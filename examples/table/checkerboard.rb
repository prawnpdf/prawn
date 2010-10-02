# encoding: utf-8

# Shows how to use the style() method with a block to style each cell with
# custom code.

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))
 
Prawn::Document.generate("checkerboard.pdf") do 

  text "Here is a checkerboard:"

  table [[""] * 8] * 8 do |t|
    t.cells.style :width => 24, :height => 24
    t.cells.style do |c| 
      c.background_color = ((c.row + c.column) % 2).zero? ? '000000' : 'ffffff'
    end
  end

  move_down 12
  text "Hope you enjoyed it!"

end
