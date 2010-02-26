module PDF
  class Inspector
    class XObject < Inspector
      attr_accessor :page_xobjects

      def initialize
        @page_xobjects = []
      end

      def resource_xobject(*params)
        @page_xobjects.last << params.first
      end

      def begin_page(*params)
        @page_xobjects << [] 
      end
    end
  end
end