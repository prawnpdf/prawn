# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Security')

    prose <<-TEXT
      Security lets you control who can read the document by defining
      a password.

      The examples include:
    TEXT

    list(
      'How to encrypt the document without the need for a password',
      'How to configure the regular user permissions',
      'How to require a password for the regular user',
      'How to set a owner password that bypass the document permissions',
    )
  end
end
