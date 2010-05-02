module Prawn
  class DocumentBuilder
    class PathConstruct < Command
      def line(document)
        document.line(params[:point1], params[:point2])
      end
    end
  end
end
