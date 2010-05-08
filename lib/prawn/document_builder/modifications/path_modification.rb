module Prawn
  class DocumentBuilder
    class PathModification < Command
      def stroke(document)
        document.stroke
      end
    end
  end
end
