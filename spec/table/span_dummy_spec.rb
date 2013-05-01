# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")
require 'set'

describe "Prawn::Table::Cell::SpanDummy" do
  before(:each) do
    @pdf = Prawn::Document.new
    @table = @pdf.table([[{:content => "Row", :colspan => 2}]])
    @master_cell = @table.cells[0,0]
    @span_dummy  = @master_cell.dummy_cells.first
  end

  it "delegates background_color to the master cell" do
    @span_dummy.background_color.should == @master_cell.background_color
  end
end
