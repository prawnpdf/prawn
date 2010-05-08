module Prawn
  class DocumentBuilder
    class FlowingTextConstruct < Command

      def setup
        @contents = params.delete(:contents) 
      end

      def text(document)
        document.text(@contents, params)
      end
    end
  end
end
