# encoding: utf-8
#
# Demonstrate use of stamps
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("stamp.pdf", :skip_page_creation => true) do

  create_stamp("odd_page_template") do
    draw_text "This is the odd page template", 
            :at => [0, bounds.top - font.height] 
    draw_text "This is also in the odd page template", :at => [0, 0] 
  end

  create_stamp("even_page_template") do
    draw_text "This is the even page template", 
            :at => [0, bounds.top - font.height] 
    draw_text "This is also in the even page template", :at => [0, 0] 
  end
  
  start_new_page
  stamp("odd_page_template")

  create_stamp("MyStamp") do
    fill_color("ff0000")
    fill_circle_at([0, 0], :radius => 20)
    fill_color("000000")
    fill_circle_at([10, 10], :radius => 20)
  end

  10.times do |i|
    10.times do |j|
      stamp_at("MyStamp", [100 + j * 50, bounds.top - 100 - i * 50])
    end
  end

  4.times do |i|
    start_new_page
    stamp("#{i % 2 == 0 ? 'even' : 'odd'}_page_template")
  end
end
