# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn::ObjectStore" do
  before(:each) do
    @store = Prawn::Core::ObjectStore.new
  end

  it "should create required roots by default, including info passed to new" do
    store = Prawn::Core::ObjectStore.new(:Test => 3)
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

describe "Prawn::ObjectStore#compact" do
  it "should do nothing to an ObjectStore with all live refs" do
    store = Prawn::Core::ObjectStore.new
    store.info.data[:Blah] = store.ref(:some => "structure")
    old_size = store.size
    store.compact

    store.size.should == old_size
  end

  it "should remove dead objects, renumbering live objects from 1" do
    store = Prawn::Core::ObjectStore.new
    store.ref(:some => "structure")
    old_size = store.size
    store.compact
    
    store.size.should.be < old_size
    store.map{ |o| o.identifier }.should == (1..store.size).to_a
  end

  it "should detect and remove dead objects that were once live" do
    store = Prawn::Core::ObjectStore.new
    store.info.data[:Blah] = store.ref(:some => "structure")
    store.info.data[:Blah] = :overwritten
    old_size = store.size
    store.compact
    
    store.size.should.be < old_size
    store.map{ |o| o.identifier }.should == (1..store.size).to_a
  end
end

