# Text was overflowing into following cells because of some issues with 
# floating point numbers in naive wrap.
#
# Resolved in: 9c357bc488d26e7bbc2e442606106106d349e232
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require "rubygems"
require "prawn"
require "prawn/layout"

@prawn_document_options = {
  :page_layout => :landscape,
  :left_margin => 36,
  :right_margin => 36,
  :top_margin => 36,
  :bottom_margin => 36}

Prawn::Document.generate("table_header_overrun.pdf", @prawn_document_options) do   

  headers = [ "Customer", "Grand\nHijynx", "Kh", "Red\nCorvette", "Rushmore", "bPnr", "lGh", "retail\nPantaloons", "sRsm", "Total\nBoxes"]
  data = [[1,0,1,0,1,0,1,0,1,0], [0,1,0,1,0,1,0,1,0,1]]

  table(data,
        :headers => headers,
        :font_size => 16,
        :horizontal_padding => 5,
        :vertical_padding => 3,
        :border => 2,
        :position => :center)  
        
  start_new_page
  
  table [['MyString']], :headers=>['Field1']

end
