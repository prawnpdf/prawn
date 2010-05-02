module Prawn
  class DocumentBuilder
    class Command
      def initialize(name, params={})
        @name    = name
        @params  = params
      end

      attr_reader :name, :params

      def setup
        # stub, replace in your subclasses
      end

      def execute(document)
         setup
         send(name, document)
         teardown
      end

      def teardown
        # stub, replace in your subclasses
      end
    end
  end
end
