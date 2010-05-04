# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("header.pdf") do 

  header = %w[Name Occupation]
  data = ["Bender Bending Rodriguez", "Bender"]

  table([header] + [data] * 50, :header => true) do
    row(0).style(:style => :bold, :background_color => 'cccccc')
  end

end
