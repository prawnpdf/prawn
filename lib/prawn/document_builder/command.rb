module Prawn
  class DocumentBuilder
    class Command
      def initialize(command, options={})
        @command = command
        @options = options
      end

      attr_reader :command, :options

      def setup
        # stub, replace in your subclasses
      end

      def execute(document)
         setup
         send(command, document)
         teardown
      end

      def teardown
        # stub, replace in your subclasses
      end
    end
  end
end
