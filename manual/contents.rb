# encoding: utf-8
#
# Generates the Prawn by example manual.

require_relative "example_helper"

Encoding.default_external = Encoding::UTF_8

Prawn::ManualBuilder::Example.generate("manual.pdf",
  :skip_page_creation => true, :page_size => "FOLIO") do

  load_page "", "cover"
  load_page "", "how_to_read_this_manual"

  # Core chapters
  load_package "basic_concepts"
  load_package "graphics"
  load_package "text"
  load_package "bounding_box"

  # Remaining chapters
  load_package "layout"
  load_page "", "table"
  load_package "images"
  load_package "document_and_page_options"
  load_package "outline"
  load_package "repeatable_content"
  load_package "security"
end
