# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Basic Concepts')

    prose <<~TEXT
      This chapter covers the minimum amount of functionality you'll need to
      start using Prawn.

      If you are new to Prawn this is the first chapter to read. Once you are
      comfortable with the concepts shown here you might want to check the
      Basics section of the Graphics, Bounding Box and Text sections.

      The examples show:
    TEXT

    list(
      'How to create new pdf documents in every possible way',
      'Where the origin for the document coordinates is. What are Bounding '\
        'Boxes and how they interact with the origin',
      'How the cursor behaves',
      'How to start new pages',
      'What the base unit for measurement and coordinates is and how to use '\
        'other convenient measures',
      "How to build custom view objects that use Prawn's DSL"
    )
  end
end
