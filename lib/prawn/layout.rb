# This is free software. Please see the LICENSE and COPYING files for details.

require_relative "table"
require_relative "grid"

module Prawn
  module Errors

    # This error is raised when table data is malformed
    #
    InvalidTableData = Class.new(StandardError)

    # This error is raised when an empty or nil table is rendered
    #
    EmptyTable = Class.new(StandardError)
  end
end
