# encoding: utf-8
#
# Low level cell and row implementation, which form the basic building
# blocks for Prawn tables.  Only necessary to know about if you plan on
# building your own table implementation from scratch or heavily modify
# the existing table system.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

Prawn::Document.generate("cell.pdf") do 
  cell = Prawn::Graphics::Cell.new(
    :border_width => 3, :padding => 10, :width => 75,
    :text => "You know that kittens are made of mud!", :document => self)
  cell2 = Prawn::Graphics::Cell.new(
    :border_width => 3, :padding => 10,
    :text => "And that puppies are made of gravy", :document => self, :font_size => 9)
  cell3 = Prawn::Graphics::Cell.new(
    :border_width => 3, :padding => 10, :width => 100, 
    :text => "This is simply the way of the world", :document => self)

    3.times do
      cellblock = Prawn::Graphics::CellBlock.new(self)
      cellblock << cell << cell2 << cell3
      cellblock.draw
    end
    
  move_down(20)  
    
  cellblock = Prawn::Graphics::CellBlock.new(self)
  cellblock << Prawn::Graphics::Cell.new(
    :border_width => 3, 
    :padding => 10, 
    :borders => [:left, :top],
    :width => 100, 
    :text => "This is simply the way of the world", :document => self)
  cellblock.draw

  stroke_line [100,100], [200,200]
end
