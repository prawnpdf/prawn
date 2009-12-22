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
      options.each { |k, v| send("#{k}=", v) }
      set_column_widths
    end                                        

    attr_writer :width
    
    def width
      @width ||= [natural_width, @pdf.bounds.width].min
    end

    protected

    def make_cells(data)
      cells = []
      data.each_with_index do |row_cells, row_number|
        row_cells.each_with_index do |cell_data, column_number|
          # TODO: differentiate based on content
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

    def natural_column_widths
      @natural_column_widths ||= (@cells.inject([]) do |ary, c| 
        ary[c.column] ||= 0
        ary[c.column] = [ary[c.column], c.width].max
        ary
      end)
    end

    def natural_width
      @natural_width ||= natural_column_widths.inject(0) { |sum, w| sum + w }
    end

    def set_column_widths
      widths = natural_column_widths

      overflow = (widths.inject { |sum, w| sum + w }) - width
      if overflow > 0
        # Shrink columns to bring natural width to width.
        # TODO: only shrink shrinkable columns; exclude non-shrinkable (images?)
        # and manually specified widths
        widths.map! { |w| w * (width.to_f / natural_width) }
      elsif overflow < 0
        # Grow columns to bring natural width to width.
        # TODO: only expandable columns. Exclude non-expandable and manual widths.
        widths.map! { |w| w * (width.to_f / natural_width) }
      end

      widths.each_with_index { |w, col_num| column(col_num).width = w }
    end

  end


end
