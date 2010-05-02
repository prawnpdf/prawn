module Prawn
  class DocumentBuilder
    class LayoutModification < Command

      def new_page(document)
        document.start_new_page(options)
      end

    end
  end
end
