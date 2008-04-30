# errors.rb : Implements custom error classes for Prawn
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

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