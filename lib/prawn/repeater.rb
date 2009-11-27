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
    def repeaters
      @repeaters ||= []
    end

    def repeat(page_filter, &block)
      repeaters << Prawn::Repeater.new(self, page_filter, &block)
    end
  end

  class Repeater
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


