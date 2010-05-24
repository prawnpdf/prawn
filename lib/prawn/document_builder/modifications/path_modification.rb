module Prawn
  class DocumentBuilder
    class PathModification < Command
      def stroke(document, layout)
        document.stroke
      end
    end
  end
end
