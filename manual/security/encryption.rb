# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Encryption'

  text do
    prose <<~TEXT
      The <code>encrypt_document</code> method, as you might have already
      guessed, is used to encrypt the PDF document.

      Once encrypted whoever is using the document will need the user password
      to read the document. This password can be set with the
      <code>:user_password</code> option. If this is not set the document will
      be encrypted but a password will not be needed to read the document.

      There are some caveats when encrypting your PDFs. Be sure to read the
      source documentation (you can find it here:
      https://github.com/prawnpdf/prawn/blob/master/lib/prawn/security.rb\u200B)
      before using this for anything super serious.
    TEXT
  end

  example eval: false, standalone: true do
    # Bare encryption. No password needed.
    Prawn::ManualBuilder::Example.generate('bare_encryption.pdf') do
      text 'See, no password was asked but the document is still encrypted.'
      encrypt_document
    end

    # Simple password. All permissions granted.
    Prawn::ManualBuilder::Example.generate('simple_password.pdf') do
      text 'You was asked for a password.'
      encrypt_document(user_password: 'foo', owner_password: 'bar')
    end
  end
end
