# encoding: utf-8

# Accessors for using a Cell inside a Table.

module Prawn
  class Table    
    class Cell

      # This module extends Cell objects when they are used in a table (as
      # opposed to standalone). Its properties apply to cells-in-tables but not
      # cells themselves.
      #
      module InTable

        # Row number (0-based).
        #
        attr_accessor :row
        
        # Column number (0-based).
        #
        attr_accessor :column

      end

    end
  end
end
