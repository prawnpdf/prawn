# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("manual.pdf") do
  text Prawn::MANUAL_TITLE, :size => 40
  
  outline.define do
    section Prawn::MANUAL_TITLE, :destination => page_number
  end
    
  load_page "foreword"
  load_page "how_to_read", "How to read this manual"
  
  # Core chapters
  load_package "basic_concepts"
  load_package "graphics"
  load_package "bounding_box"
  load_package "text"
  
  # Remaining chapters
  load_package "table"
  load_package "images"
  load_package "outline"
  load_package "security"
  load_package "stamp"
end
