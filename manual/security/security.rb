# encoding: utf-8
#
# Examples for document encryption.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("security.pdf") do
  build_package("security", [
      { :name => "encryption",
        :eval_source => false,
        :full_source => true }
    ]

  ) do
    text "Security lets you control who can read the document by defining a password.

    The examples include:"

    list( "How to encrypt the document without the need for a password",
          "How to configure the regular user permitions",
          "How to require a password for the regular user",
          "How to set a owner password that bypass the document permissions"
        )
  end
end
