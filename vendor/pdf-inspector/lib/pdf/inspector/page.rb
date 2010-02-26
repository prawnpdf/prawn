module PDF
  class Inspector
    class Page < Inspector
      attr_reader :pages
      
      def initialize
        @pages = []
      end

      def begin_page(params)
        @pages << {:size => params[:MediaBox][-2..-1], :strings => []}
      end                       

      def show_text(*params)
        @pages.last[:strings] << params[0]
      end

      def show_text_with_positioning(*params)      
        # ignore kerning information
        @pages.last[:strings] << params[0].reject { |e| Numeric === e }.join
      end
      
    end   
  end
end
