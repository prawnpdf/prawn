require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate('float.pdf') do
  float do
    bounding_box [bounds.width / 2.0, bounds.top], :width => 100 do
      text "Hello world. " * 50
    end
  end

  text "Hello world again"
end
