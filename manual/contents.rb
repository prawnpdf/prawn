# Generates the Prawn by example manual.

require_relative 'example_helper'

def prawn_manual_document
  old_default_external_encoding = Encoding.default_external
  Encoding.default_external = Encoding::UTF_8

  # We need to use a fixed trailer ID, otherwise the test for
  # unintended manual changes will always trigger because of
  # a random trailer ID.
  trailer_id = PDF::Core::ByteString.new('PrawnPrawnPrawnP')
  Prawn::ManualBuilder::Example.new(
    skip_page_creation: true,
    page_size: 'FOLIO',
    trailer: { ID: [trailer_id, trailer_id] }
  ) do
    load_page '', 'cover'
    load_page '', 'how_to_read_this_manual'

    # Core chapters
    load_package 'basic_concepts'
    load_package 'graphics'
    load_package 'text'
    load_package 'bounding_box'

    # Remaining chapters
    load_package 'layout'
    load_page '', 'table'
    load_package 'images'
    load_package 'document_and_page_options'
    load_package 'outline'
    load_package 'repeatable_content'
    load_package 'security'
  end
ensure
  Encoding.default_external = old_default_external_encoding
end
