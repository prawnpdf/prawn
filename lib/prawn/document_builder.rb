require "prawn/document_builder/command"
require "prawn/document_builder/constructs"
require "prawn/document_builder/modifications"

module Prawn
  class DocumentBuilder

    def initialize
      @commands = []
    end

    attr_reader :commands

    def start_new_page(options={})
      commands << LayoutModification.new(:new_page, options)
    end

    def compile
      document = ::Prawn::Document.new

      commands.each do |c|
        c.execute(document)
      end

      document
    end

  end
end
