module Prawn
  class TextBox
    
    attr_accessor :text, :width, :padding, :border
    
    def initialize(text, options = {})
      @text = text
      @width = options[:width]
      @padding = options[:padding] || 0
      @border = options[:border] || 0
      
      @metrics = Prawn::Font::AFM["Helvetica"]
      @font_size = 12
    end
    
    def height
      inner_height + (padding * 2)
    end
    
    def inner_height
      lines * @font_size
    end
    
    def inner_width
      width - (padding * 2)
    end
    
    
    def render_on_pdf(pdf, at)
      x, y = *at
      
      pdf.bounding_box([x + padding, y - padding], :width => inner_width, :height => inner_height) do
        pdf.text text, :size => @font_size
        
        if border > 0
          pdf.line_width = border
          pdf.polygon [pdf.bounds.left - padding,  pdf.bounds.top + padding],
                      [pdf.bounds.right + padding, pdf.bounds.top + padding],
                      [pdf.bounds.right + padding, pdf.bounds.bottom - padding],
                      [pdf.bounds.left - padding, pdf.bounds.bottom - padding]
          pdf.stroke
        end
      end
    end
    
  private
  
    def lines
      wrapped_text.lines.size
    end
  
    def wrapped_text
      @metrics.naive_wrap(text, inner_width, @font_size)
    end
    
  end
end