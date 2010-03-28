# encoding: utf-8    

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate('column_gutter_grid.pdf') do |p|
  p.define_grid(:columns => 3, :rows => 10, :column_gutter => 10)
  
  p.grid.rows.times do |i|
    p.grid.columns.times do |j|
      b = p.grid(i,j)
      p.bounding_box b.top_left, :width => b.width, :height => b.height do
        p.text b.name
        p.stroke do
          p.rectangle(p.bounds.top_left, b.width, b.height)
        end
      end
    end
  end
end

