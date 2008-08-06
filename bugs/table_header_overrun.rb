$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'

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

end
