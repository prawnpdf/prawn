require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("security_hello_foo.pdf") do
  text "Hello, world!"
  encrypt_document :user_password => 'foo', :owner_password => 'bar',
    :permissions => { :print_document => false }
end

