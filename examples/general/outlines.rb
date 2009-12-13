# encoding: utf-8
#
# This example demonstrates the use of the the outlines option for a new document
# it sets an initial outline item with a title
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"


Prawn::Document.generate('outlines.pdf') do
  text "Page 1. This is the first Chapter. "
  start_new_page
  text "Page 2. More in the first Chapter. "
  start_new_page
  text "Page 3. This is the second Chapter. It has a subsection. "
  start_new_page
  text  "Page 4. More in the second Chapter. "
  render_outline do
    section ['Chapter 1', 1] do 
      page ['Page 1', 1]
      page ['Page 2', 2]
    end
    section ['Chapter 2', 3] do 
      section ['Chapter 2 Subsection', 3] do
        page ['Page 3', 3]
      end
      page ['Page 4', 4]
    end
  end
  
end
