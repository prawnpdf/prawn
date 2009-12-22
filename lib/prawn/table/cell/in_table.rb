# encoding: utf-8

# Accessors for using a Cell inside a Table.

module Prawn
  class Table    
    class Cell

      module InTable
        attr_accessor :row
        attr_accessor :column
      end

    end
  end
end
