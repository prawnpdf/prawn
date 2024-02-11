# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Document Metadata'

  text do
    prose <<~TEXT
      To set the document metadata just pass a hash to the <code>:info</code>
      option when creating new documents.

      The keys in the example below are arbitrary, so you may add whatever keys
      you want.
    TEXT
  end

  example eval: false, standalone: true do
    info = {
      Title: 'My title',
      Author: 'John Doe',
      Subject: 'My Subject',
      Keywords: 'test metadata ruby pdf dry',
      Creator: 'ACME Soft App',
      Producer: 'Prawn',
      CreationDate: Time.now
    }

    Prawn::Document.generate('example.pdf', info: info) do
      text 'This is a test of setting metadata properties via the info option.'
      text 'While the keys are arbitrary, the above example sets common attributes.'
    end
  end
end
