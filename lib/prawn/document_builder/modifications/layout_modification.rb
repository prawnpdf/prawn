module Prawn
  class DocumentBuilder
    class LayoutModification < Command
      def new_page(document)
        document.start_new_page(params)
      end
    end
  end
end
