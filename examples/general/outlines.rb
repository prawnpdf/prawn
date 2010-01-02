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
    section 'Chapter 1', :page => 1, :closed => true do 
      page 1, :title => 'Page 1'
      page 2, :title => 'Page 2'
    end
    section 'Chapter 2', :page => 3 do 
      section 'Chapter 2 Subsection' do
        page 3, :title => 'Page 3'
      end
      page 4, :title => 'Page 4'
    end
  end
  start_new_page
  text "Page 5. Appendix"
  start_new_page 
  text "Page 6. More in the Appendix"
  add_outline_section do
    section 'Appendix', :page => 5 do
      page 5, :title => 'Page 5'
      page 6, :title => 'Page 6'
    end
  end
  go_to_page 4
  start_new_page 
  text "inserted before the Appendix"
  insert_section_after :title => 'Chapter 2' do
    page page_number, :title => "Pre-Appendix"
  end
  go_to_page 7
  start_new_page
  text "One last page"
  insert_section_after :title => 'Page 6' do 
    page page_number, :title => "Inserted after 6"
  end
  
end
