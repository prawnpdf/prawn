# encoding: utf-8
#
# table.rb: Table drawing functionality.
#
# Copyright December 2009, Brad Ediger. All rights reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'prawn/table/accessors'
require 'prawn/table/cell'
require 'prawn/table/cell/in_table'
require 'prawn/table/cell/text'

module Prawn

  class Document
    
    # TODO: doc
    def table(data, options={})
      Table.new(data, self, options)
    end

  end

  class Table  

    def initialize(data, document, options={})     
      @pdf = document
      @cells = make_cells(data)
      @options = options
    end                                        
    

    protected

    def make_cells(data)
      cells = []
      data.each_with_index do |row_cells, row_number|
        row_cells.each_with_index do |cell_data, column_number|
          # TODO: differentiate based on context
          # TODO: :at
          cell = Cell::Text.new(@pdf, [0, 0], :content => cell_data)
          cell.extend(Cell::InTable)
          cell.row = row_number
          cell.column = column_number
          cells << cell
        end
      end
      cells
    end


  end


end
