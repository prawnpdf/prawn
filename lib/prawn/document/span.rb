module Prawn
  class Document
    def span(width, options={})
      Prawn.verify_options [:position], options
      original_position = self.y      
      
      # FIXME: How many effing times do I want to write this same code?
      left_boundary = case(options[:position] || :left)
      when :left
        margin_box.absolute_left
      when :center
        margin_box.absolute_left + margin_box.width / 2.0 - width /2.0
      when :right
        margin_box.absolute_right - width
      when Numeric
        margin_box.absolute_left + options[:position]
      else
        raise ArgumentError, "Invalid option for :position"
      end
      
      # we need to bust out of whatever nested bounding boxes we're in.
      canvas do
        bounding_box([left_boundary, 
                      margin_box.absolute_top], :width => width) do
          self.y = original_position
          yield
        end
      end          
    end
  end
end