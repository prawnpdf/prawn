# encoding: utf-8
#
# generates outline dictionary and items for document
#
# Author Jonathan Greenberg

require 'forwardable'
require_relative "../pdf/core/outline"

module Prawn

  class Document

    # Lazily instantiates an Outline object for document. This is used as point of entry
    # to methods to build the outline tree.
    def outline
      @outline ||= PDF::Core::Outline.new(self)
    end

  end

end
