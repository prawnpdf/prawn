# encoding: utf-8
#
# Demonstration of Document#span, which is used for generating flowing
# columns of text.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("span.pdf") do
  
  # Spans will typically be used outside of bounding boxes as a way to build
  # single columns of flowing text that span across pages.
  #
  span(350, :position => :center) do
    text "Here's some centered text in a 350 point column. " * 100
  end
  
  # Spans are not really compatible with bounding boxes because they break
  # the nesting chain and also may position text outside of the bounding box
  # boundaries, but sometimes you may wish to use them anyway for convenience
  # Here's an example of how to do that dynamically.
  # 
  bounding_box([50,300], :width => 400) do
    text "Here's some default bounding box text. " * 10 
    span(bounds.width, 
      :position => bounds.absolute_left - margin_box.absolute_left) do
      text "The rain in spain falls mainly on the plains. " * 300
    end
  end
end