# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Permissions'

  text do
    prose <<~TEXT
      Some permissions may be set for the regular user with the following
      options: <code>:print_document</code>, <code>:modify_contents</code>,
      <code>:copy_contents</code>, <code>:modify_annotations</code>. All this
      options default to <code>true</code>, so if you'd like to revoke just set
      them to <code>false</code>.

      A user may bypass all permissions if he provides the owner password which
      may be set with the <code>:owner_password</code> option. This option may
      be set to <code>:random</code> so that users will never be able to bypass
      permissions.

      There are some caveats when encrypting your PDFs. Be sure to read the source
      documentation (you can find it here:
      https://github.com/prawnpdf/prawn/blob/master/lib/prawn/security.rb\u200B)
      before using this for anything super serious.
    TEXT
  end

  example eval: false, standalone: true do
    # User cannot print the document.
    Prawn::Document.generate('cannot_print.pdf') do
      text "If you used the user password you won't be able to print the doc."
      encrypt_document(
        user_password: 'foo',
        owner_password: 'bar',
        permissions: { print_document: false }
      )
    end

    # All permissions revoked and owner password set to random
    Prawn::Document.generate('no_permissions.pdf') do
      text "You may only view this and won't be able to use the owner password."
      encrypt_document(
        user_password: 'foo',
        owner_password: :random,
        permissions: {
          print_document: false,
          modify_contents: false,
          copy_contents: false,
          modify_annotations: false
        }
      )
    end
  end
end
