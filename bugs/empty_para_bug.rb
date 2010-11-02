# multiple line-returns like \n\n with no text between them cause new pages rather than extra blank lines [#162]

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
puts $LOAD_PATH
require "prawn"
require "prawn/core"
require "prawn/document"
require "prawn/text"


p = Prawn::Document.new
p_break = " \n\n"
      lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.#{p_break}Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.#{p_break}Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."    
# also works if lorem is a formatted text array
#lorem =  [{:text=>"This is some ", :styles=>[], :color=>nil, :link=>nil, :anchor=>nil, :font=>nil, :size=>nil, :character_spacing=>nil}, {:text=>"italic", :styles=>[:italic], :color=>nil, :link=>nil, :anchor=>nil, :font=>nil, :size=>nil, :character_spacing=>nil}, {:text=>" and ", :styles=>[], :color=>nil, :link=>nil, :anchor=>nil, :font=>nil, :size=>nil, :character_spacing=>nil}, {:text=>"bold", :styles=>[:bold], :color=>nil, :link=>nil, :anchor=>nil, :font=>nil, :size=>nil, :character_spacing=>nil}, {:text=>" text.", :styles=>[], :color=>nil, :link=>nil, :anchor=>nil, :font=>nil, :size=>nil, :character_spacing=>nil}]
options = {
          :inline_format => false,
          :indent_paragraphs => 13,
          }
p.bounding_box [0,p.bounds.top-30], :width=>400 do
  p.text(lorem*4, options)
end  
p.render_file("empty_para_bug.pdf")



