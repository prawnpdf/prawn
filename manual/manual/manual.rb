# encoding: utf-8
#
# Generates the Prawn by example manual.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("manual.pdf", :skip_page_creation => true) do
  load_page "cover"
  load_page "foreword"
  load_page "how_to_read", "How to read this manual"
  
  # Core chapters
  load_package "basic_concepts"
  load_package "graphics"
  load_package "text"
  load_package "bounding_box"
  
  # Remaining chapters
  load_package "layout"
  load_package "table"
  load_package "images"
  load_package "document_and_page_options"
  load_package "outline"
  load_package "repeatable_content"
  load_package "templates"
  load_package "security"
end
