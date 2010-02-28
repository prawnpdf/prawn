# encoding: utf-8    

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate('bounding_box_grid.pdf') do |p|
  p.define_grid(:columns => 5, :rows => 8, :gutter => 10)
  
  p.stroke_color = "ff0000"
  
  p.grid.rows.times do |i|
    p.grid.columns.times do |j|
      p.grid(i,j).bounding_box do
        p.text p.grid(i,j).name
        p.stroke do
          p.rectangle(p.bounds.top_left, p.bounds.width, p.bounds.height)
        end
      end
    end
  end
end

