warn "Templates are no longer supported in Prawn!\n" +
     "This code is for experimental testing only, and\n" +
     "will extracted into its own gem in a future Prawn release"

module Prawn
  module Templates

  end
end

Prawn::Document::VALID_OPTIONS << :template
Prawn::Document.send(:include, Prawn::Templates)
