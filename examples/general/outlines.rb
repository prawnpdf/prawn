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
  outline.section 'Preface' do
    outline.page nil, :title => 'Preface' 
  end
  outline.define do 
    section 'Chapter 1', :page => 1, :closed => true do 
      page 1, :title => 'Page 1'
      page 2, :title => 'Page 2'
    end
    section 'Chapter 2', :page => 3 do 
      section 'Chapter 2 Subsection' do
        page nil,  :title => 'Page 3'
      end
      page 4, :title => 'Page 4'
    end
  end
  start_new_page
  text "Page 5. Appendix"
  start_new_page 
  text "Page 6. More in the Appendix"
  outline.section 'Appendix', :page => 5 do
    outline.page 5, :title => 'Page 5'
    outline.page 6, :title => 'Page 6'
  end
  go_to_page 4
  start_new_page 
  text "inserted before the Appendix"
  outline.update do 
    insert_section_after 'Chapter 2' do
      page page_number, :title => "Pre-Appendix"
    end
  end
  go_to_page 7
  start_new_page
  text "One last page"
  outline.insert_section_after 'Page 6' do 
    outline.page page_number, :title => "Inserted after 6"
  end 
  outline.add_subsection_to 'Chapter 1', :first do
    outline.section 'Inserted subsection', :page => 1 do
      outline.page 1, :title => "Page 1 again" 
    end
  end 
  outline.update do
    page nil, :title => "Last Page" 
  end  
  outline.page nil, :title => "Very Last Page" 
end
