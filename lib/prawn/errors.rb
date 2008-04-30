module Prawn
  module Errors
     # This error is raised when Prawn::PdfObject() encounters a Ruby object it
     # cannot convert to PDF
     #
     class FailedObjectConversion < StandardError; end
     
     # This error is raised when Document#page_layout is set to anything
     # other than :portrait or :landscape
     class InvalidPageLayout < StandardError; end 
  end
end   