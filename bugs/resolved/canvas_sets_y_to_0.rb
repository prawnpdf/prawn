# As of 7e94d25828021732f7872934cb91430ef798cd86, Document#canvas
# sets pdf.y to 0 after executing a block, which is probably not useful for 
# anyone.  It should retain the y position present at the end of the block.
#
# This was resolved in 998a5c3fad40c9e0a79e1468e3a83815ed948a74 [#88]
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..','lib')
require "prawn/core"

Prawn::Document.generate("canvas_sets_y_to_0.pdf") do
  
  canvas { text "blah" }
 
  text "Here's my sentence. by satoko"
end
