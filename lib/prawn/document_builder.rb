require "prawn/document_builder/command"
require "prawn/document_builder/constructs"
require "prawn/document_builder/modifications"

module Prawn
  class DocumentBuilder

    def initialize
      @commands = []
    end

    attr_reader :commands

     def compile
      document = ::Prawn::Document.new

      commands.each do |c|
        c.execute(document)
      end

      document
    end

    extendable_features = Module.new do
      def start_new_page(options={})
        commands << LayoutModification.new(:new_page, options)
      end

      def line(point1, point2)
        commands << PathConstruct.new(:line, :point1 => point1, 
                                             :point2 => point2)
      end

      def stroke
        commands << PathModification.new(:stroke)
      end
    end

    include extendable_features
  end
end
