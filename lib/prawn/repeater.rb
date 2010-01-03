# encoding: utf-8
#
# repeater.rb : Implements repeated page elements.
# Heavy inspired by repeating_element() in PDF::Wrapper
#   http://pdf-wrapper.rubyforge.org/
#
# Copyright November 2009, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn

  class Document

    # A list of all repeaters in the document.
    # See Document#repeat for details
    #
    def repeaters
      @repeaters ||= []
    end

    # Provides a way to execute a block of code repeatedly based on a
    # page_filter.  Since Stamp is used under the hood, this method is very space
    # efficient.
    #
    # Available page filters are:
    #   :all        -- repeats on every page
    #   :odd        -- repeats on odd pages
    #   :even       -- repeats on even pages
    #   some_array  -- repeats on every page listed in the array
    #   some_range  -- repeats on every page included in the range
    #   some_lambda -- yields page number and repeats for true return values 
    #
    # Example:
    #
    #   Prawn::Document.generate("repeat.pdf", :skip_page_creation => true) do
    #
    #     repeat :all do
    #       text "ALLLLLL", :at => bounds.top_left
    #     end
    #
    #     repeat :odd do
    #       text "ODD", :at => [0,0]
    #     end
    #
    #     repeat :even do
    #       text "EVEN", :at => [0,0]
    #     end
    # 
    #     repeat [1,2] do 
    #       text "[1,2]", :at => [100,0]
    #     end
    #
    #     repeat 2..4 do
    #       text "2..4", :at => [200,0]
    #     end
    #
    #     repeat(lambda { |pg| pg % 3 == 0 }) do
    #       text "Every third", :at => [250, 20]
    #     end
    #
    #     10.times do 
    #       start_new_page
    #       text "A wonderful page", :at => [400,400]
    #     end
    #
    #   end
    #
    def repeat(page_filter, &block)
      repeaters << Prawn::Repeater.new(self, page_filter, &block)
    end
  end

  class Repeater #:nodoc:
    class << self
      attr_writer :count

      def count
        @count ||= 0
      end
    end

    attr_reader :name

    def initialize(document, page_filter, &block)
      @document    = document
      @page_filter = page_filter
      @stamp_name  = "prawn_repeater(#{Repeater.count})"

      @document.create_stamp(@stamp_name, &block)

      Repeater.count += 1
    end

    def match?(page_number)
      case @page_filter
      when :all
        true
      when :odd
        page_number % 2 == 1
      when :even
        page_number % 2 == 0
      when Range, Array
        @page_filter.include?(page_number)
      when Proc
        @page_filter.call(page_number)
      end
    end

    def run(page_number)
      @document.stamp(@stamp_name) if match?(page_number)
    end

  end
end


