# encoding: utf-8
#
# This example demonstrates the use of the the outlines option for a new document
# it sets an initial outline item with a title
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate('outlines.pdf') do
  text "Page 1. This is the first Chapter. "
  start_new_page
  text "Page 2. More in the first Chapter. "
  start_new_page
  text "Page 3. This is the second Chapter. It has a subsection. "
  start_new_page
  text  "Page 4. More in the second Chapter. "
  outline.section 'Preface' do
    outline.page :title => 'Preface' 
  end
  outline.define do 
    section 'Chapter 1', :destination => 1, :closed => true do 
      page :destination => 1, :title => 'Page 1'
      page :destination => 2, :title => 'Page 2'
    end
    section 'Chapter 2', :destination => 3 do 
      section 'Chapter 2 Subsection' do
        page :title => 'Page 3'
      end
      page :destination => 4, :title => 'Page 4'
    end
  end
  start_new_page
  text "Page 5. Appendix"
  start_new_page 
  text "Page 6. More in the Appendix"
  outline.section 'Appendix', :destination => 5 do
    outline.page :destination => 5, :title => 'Page 5'
    outline.page :destination => 6, :title => 'Page 6'
  end
  go_to_page 4
  start_new_page 
  text "inserted before the Appendix"
  outline.update do 
    insert_section_after 'Chapter 2' do
      page :destination => page_number, :title => "Pre-Appendix"
    end
  end
  go_to_page 7
  start_new_page
  text "One last page"
  outline.insert_section_after 'Page 6' do 
    outline.page :destination => page_number, :title => "Inserted after 6"
  end 
  outline.add_subsection_to 'Chapter 1', :first do
    outline.section 'Inserted subsection', :destination => 1 do
      outline.page :destination => 1, :title => "Page 1 again" 
    end
  end 
  start_new_page
  text "Really this is the last page."
  outline.update do
    page :destination => page_number, :title => "Last Page" 
  end 
  start_new_page
  text "OK, I lied; this is the very last page."
  outline.page :destination => page_number, :title => "Very Last Page" 
end
