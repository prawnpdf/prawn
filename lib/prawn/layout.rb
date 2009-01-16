require "prawn/table"

module Prawn::Errors
 # This error is raised when table data is malformed
 #
 class InvalidTableData < StandardError; end 

 # This error is raised when an empty or nil table is rendered
 #
 class EmptyTable < StandardError; end 
end
