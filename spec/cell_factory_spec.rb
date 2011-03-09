require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

class Foo < Prawn::Table::Cell
  def self.can_render_with?(content)
    content.kind_of? String
  end
end

describe 'Prawn::Table::CellFactory' do
  describe '#register' do
    it "should raise an exception if not a Prawn::Table::Cell" do
      lambda {
        Prawn::Table::CellFactory.register(NilClass)
      }.should.raise(ArgumentError)
    end

    it 'should accept a subclass of Prawn::Table::Cell' do
      lambda {
        Prawn::Table::CellFactory.register(Foo)
      }.should.not.raise(ArgumentError)
    end
  end

  describe '#find_cell_for_content' do
    setup do
      @currently_registered = Prawn::Table::CellFactory.instance_variable_get("@cells").dup
      Prawn::Table::CellFactory.clear
      Prawn::Table::CellFactory.register(Foo)
    end

    teardown do
      Prawn::Table::CellFactory.clear
      Prawn::Table::CellFactory.instance_variable_set("@cells", @currently_registered.dup)
    end

    it 'should find the cell for String' do
      Prawn::Table::CellFactory.find_cell_for_content("Blah").should.equal(Foo)
    end

    it 'should not find the cell for Fixnum' do
      Prawn::Table::CellFactory.find_cell_for_content(1).should.not.equal(Foo)
    end
  end
end