module Prawn
  class DocumentBuilder
    class FlowingTextConstruct < Command
      def setup
        @contents = params.delete(:contents) 
      end

      def text(document, layout)
        box = layout.remaining_space
        excess = document.text_box(@contents, { :at => box.top_left, :width => box.width, :height => box.height }.merge(params))
        unless excess.empty?
          layout.overflow(FlowingTextConstruct.new(:text, params.merge(:contents => excess)))  
        end
      end

    end
  end
end
