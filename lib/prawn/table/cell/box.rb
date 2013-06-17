# encoding: utf-8

# text/rectangle.rb : Implements text boxes
#
# Copyright November 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  class Table
    class Cell
      # Generally, one would use the Prawn::Table#new method to create a table
      #
      class Box < Prawn::Table::Cell::Formatted::Box

        def initialize(string, options={})
          super([{ :text => string }], options)
        end

        def render(flags={})
          leftover = super(flags)
          leftover.collect { |hash| hash[:text] }.join
        end

      end
    end
  end
end
