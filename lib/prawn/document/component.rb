module Prawn
  class Document
    module Component

      # @group Extension API

      def draw drawer, *args
        drawer.call self, *args
      end

    end
  end
end
