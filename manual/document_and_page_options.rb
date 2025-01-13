# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Document and Page Options')

    prose <<-TEXT
      So far we've already seen how to create new documents and start new
      pages. This chapter expands on the previous examples by showing other
      options available. Some of the options are only available when creating
      new documents.

      The examples show:
    TEXT

    list(
      'How to configure page size',
      'How to configure page margins',
      'How to use a background image',
      'How to add metadata to the generated PDF',
    )
  end
end
