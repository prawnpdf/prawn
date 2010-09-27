# encoding: utf-8
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))
 
Prawn::Document.generate("header.pdf") do 

  header = %w[Name Occupation]
  data = ["Bender Bending Rodriguez", "Bender"]

  table([header] + [data] * 50, :header => true) do
    row(0).style(:font_style => :bold, :background_color => 'cccccc')
  end

end
