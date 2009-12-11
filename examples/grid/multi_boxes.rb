# encoding: utf-8    

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate('multi_boxes.pdf') do |p|
  p.define_grid(:columns => 5, :rows => 8, :gutter => 10)
  
  p.grid.rows.times do |i|
    p.grid.columns.times do |j|
      p.grid(i,j).bounding_box do
        p.text p.grid(i,j).name
        p.stroke_color = "cccccc"
        p.stroke do
          p.rectangle(p.bounds.top_left, p.bounds.width, p.bounds.height)
        end
      end
    end
  end
  
  g = p.grid([0,0], [1,1])
  g.bounding_box do
    p.move_down 12
    p.text g.name
    p.stroke_color = "333333"
    p.stroke do
      p.rectangle(p.bounds.top_left, p.bounds.width, p.bounds.height)
    end
  end
 
  g = p.grid([3,0], [3,3])
  g.bounding_box do
    p.move_down 12
    p.text g.name
    p.stroke_color = "333333"
    p.stroke do
      p.rectangle(p.bounds.top_left, p.bounds.width, p.bounds.height)
    end
  end
 
  g = p.grid([4,0], [5,1])
  g.bounding_box do
    p.move_down 12
    p.text g.name
    p.stroke_color = "333333"
    p.stroke do
      p.rectangle(p.bounds.top_left, p.bounds.width, p.bounds.height)
    end
  end
 
end

