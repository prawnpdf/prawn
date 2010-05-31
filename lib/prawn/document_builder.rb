require "prawn/document_builder/command"
require "prawn/document_builder/constructs"
require "prawn/document_builder/modifications"
require "prawn/document_builder/layout"

module Prawn
  class DocumentBuilder
    def initialize
      @commands = []
    end

    attr_accessor :commands

    def compile
      document = ::Prawn::Document.new
      layout   = ::Prawn::DocumentBuilder::Layout.new(self, document)

      original_commands = commands.dup

      while c = commands.shift
        c.execute(document, layout)
      end

      self.commands = original_commands

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

      def text(contents, options={})
        options = options.merge(:contents => contents)
        commands << FlowingTextConstruct.new(:text, options)
      end

      def stroke
        commands << PathModification.new(:stroke)
      end
    end

    include extendable_features
  end
end
