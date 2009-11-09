# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

class ExampleClass
  extend Prawn::Extendable
  
  def example
    :example
  end
end

module ExampleExtension
  def example
    "extended #{super}"
  end
end

ExampleClass.extensions << ExampleExtension

describe "Extendable" do
  it "should add extension management to a class" do
    assert_kind_of(Prawn::Extendable, ExampleClass)
    assert_instance_of(Array, ExampleClass.extensions)
  end

  it "should mix all extensions into new instances" do
    assert(!ExampleClass.extensions.empty?, "There were no extensions added")
    instance = ExampleClass.new
    ExampleClass.extensions.each do |extension|
      assert_kind_of(extension, instance)
    end
  end

  it "should allow for the normal use of super" do
    ExampleClass.new.example.should == "extended example"
  end
end 
