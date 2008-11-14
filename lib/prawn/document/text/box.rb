module Prawn
  class Document
    
    def text_box(text,options)
      Text::Box.new(text, options.merge(:for => self)).render
    end
    
    module Text
      class Box
        def initialize(text,options={})
          @document  = options[:for]
          @text      = text
          @at        = options[:at] || [0, @document.y - @document.bounds.absolute_bottom]
          @width     = options[:width] || @document.bounds.width
          @height    = options[:height]
          @overflow  = options[:overflow] || :truncate
        end
        
        def render
          x,y = @at
          
          unless @overflow == :expand
            fit_text_to_box
          end
          
          @document.y = @document.bounds.absolute_bottom + y   
          @document.span(@width, :position => x) do
            @document.text @text
          end
            
        end
        
        private
        
        def fit_text_to_box
          text = @document.font.metrics.naive_wrap(@text,
            @width, @document.font.size)
            
          max_lines = (@height / @document.font.height).floor
          
          unless text.lines.size < max_lines
            @text = text.lines[0...max_lines].join
            case(@overflow)
            when :ellipses
              @text[-3..-1] = "..."
            end
          end 
        end
        
      end
    end
  end
end