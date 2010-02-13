# encoding: utf-8
#
# This example demonstrates how to make use of Prawn's repeating element
# support.  Note that all repeated elements are generated using XObjects, so
# they should be pretty efficient.
#
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("repeat.pdf", :skip_page_creation => true) do

  repeat :all do
    draw_text "ALLLLLL", :at => bounds.top_left
  end

  repeat :odd do
    draw_text "ODD", :at => [0,0]
  end

  repeat :even do
    draw_text "EVEN", :at => [0,0]
  end

  repeat [1,2] do 
    draw_text "[1,2]", :at => [100,0]
  end

  repeat 2..4 do
    draw_text "2..4", :at => [200,0]
  end

  repeat(lambda { |pg| pg % 3 == 0 }) do
    draw_text "Every third", :at => [250, 20]
  end
  
  repeat(:all, :dynamic => true) do
    draw_text page_number, :at => [500, 0]
  end

  10.times do 
    start_new_page
    draw_text "A wonderful page", :at => [400,400]
  end

end


