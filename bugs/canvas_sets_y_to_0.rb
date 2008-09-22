# As of 7e94d25828021732f7872934cb91430ef798cd86, Document#canvas
# sets pdf.y to 0 after executing a block, which is probably not useful for 
# anyone.  It should retain the y position present at the end of the block.

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("canvas_sets_y_to_0.pdf") do
  
  canvas do
    text "blah"
  end
 
  text "Here's my sentence. by satoko"
end