module Prawn
  class DocumentBuilder
    class Command
      def initialize(name, params={})
        @name    = name
        @params  = params
      end

      attr_reader :name
      attr_accessor :params

      def setup
        # stub, replace in your subclasses
      end

      def execute(document)
         save_params
         setup
         send(name, document)
         teardown
         restore_params
      end

      def teardown
        # stub, replace in your subclasses
      end

      def save_params
        @original_params = @params.dup
      end

      def restore_params
        @params = @original_params
      end
    end
  end
end
