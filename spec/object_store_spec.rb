# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn::ObjectStore" do
  before(:each) do
    @store = Prawn::ObjectStore.new
  end

  it "should create required roots by default, including info passed to new" do
    store = Prawn::ObjectStore.new(:Test => 3)
    store.size.should == 3 # 3 default roots
    store.info.data[:Test].should == 3
    store.pages.data[:Count].should == 0
    store.root.data[:Pages].should == store.pages
  end

  it "should add to its objects when ref() is called" do
    count = @store.size
    @store.ref("blah")
    @store.size.should == count + 1
  end

  it "should accept push with a Prawn::Reference" do
    r = Prawn::Reference(123, "blah")
    @store.push(r)
    @store[r.identifier].should == r
  end

  it "should accept arbitrary data and use it to create a Prawn::Reference" do
    @store.push(123, "blahblah")
    @store[123].data.should == "blahblah"
  end

  it "should be Enumerable, yielding in order of submission" do
    # higher IDs to bypass the default roots
    [10, 11, 12].each do |id|
      @store.push(id, "some data #{id}")
    end
    @store.map{|ref| ref.identifier}[-3..-1].should == [10, 11, 12]
  end
end
