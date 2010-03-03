require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

def tree_dump(tree)
  if tree.is_a?(Prawn::Core::NameTree::Node)
    "[" + tree.children.map { |child| tree_dump(child) }.join(",") + "]"
  else
    "#{tree.name}=#{tree.value}"
  end
end

def tree_add(tree, *args)
  args.each do |(name, value)|
    tree.add(name, value)
  end
end

def tree_value(name, value)
  Prawn::Core::NameTree::Value.new(name, value)
end

class RefExposingDocument < Prawn::Document
  def object_store
    state.store
  end
end

describe "Name Tree" do     
  before(:each) { create_pdf(RefExposingDocument) }

  it "should have no children when first initialized" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    node.children.length.should == 0
  end

  it "should have no subtrees while child limit is not reached" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3])
    tree_dump(node).should == "[one=1,three=3,two=2]"
  end

  it "should split into subtrees when limit is exceeded" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3], ["four", 4])
    tree_dump(node).should == "[[four=4,one=1],[three=3,two=2]]"
  end

  it "should create a two new references when root is split" do
    ref_count = @pdf.object_store.length
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3], ["four", 4])
    @pdf.object_store.length.should.equal ref_count+2
  end
  
  it "should create a one new reference when subtree is split" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3], ["four", 4])

    ref_count = @pdf.object_store.length # save when root is split
    tree_add(node, ["five", 5], ["six", 6], ["seven", 7])
    tree_dump(node).should == "[[five=5,four=4,one=1],[seven=7,six=6],[three=3,two=2]]"
    @pdf.object_store.length.should.equal ref_count+1
  end

  it "should keep tree balanced when subtree split cascades to root" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3], ["four", 4])
    tree_add(node, ["five", 5], ["six", 6], ["seven", 7], ["eight", 8])
    tree_dump(node).should == "[[[eight=8,five=5],[four=4,one=1]],[[seven=7,six=6],[three=3,two=2]]]"
  end

  it "should maintain order of already properly ordered nodes" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["eight", 8], ["five", 5], ["four", 4], ["one", 1])
    tree_add(node, ['seven', 7], ['six', 6], ['three', 3], ['two', 2])
    tree_dump(node).should == "[[[eight=8,five=5],[four=4,one=1]],[[seven=7,six=6],[three=3,two=2]]]"
  end

  it "should emit only :Names key with to_hash if root is only node" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3])
    node.to_hash.should.equal(
      { :Names => [tree_value("one", 1), tree_value("three", 3), tree_value("two", 2)] }
    )
  end

  it "should emit only :Kids key with to_hash if root has children" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3], ["four", 4])
    node.to_hash.should.equal({ :Kids => node.children.map { |child| child.ref } })
  end

  it "should emit :Limits and :Names keys with to_hash for leaf node" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3], ["four", 4])
    node.children.first.to_hash.should.equal(
      { :Limits => %w(four one),
        :Names => [tree_value("four", 4), tree_value("one", 1)] }
    )
  end

  it "should emit :Limits and :Kids keys with to_hash for inner node" do
    node = Prawn::Core::NameTree::Node.new(@pdf, 3)
    tree_add(node, ["one", 1], ["two", 2], ["three", 3], ["four", 4])
    tree_add(node, ["five", 5], ["six", 6], ["seven", 7], ["eight", 8])
    tree_add(node, ["nine", 9], ["ten", 10], ["eleven", 11], ["twelve", 12])
    tree_add(node, ["thirteen", 13], ["fourteen", 14], ["fifteen", 15], ["sixteen", 16])
    node.children.first.to_hash.should.equal(
      { :Limits => %w(eight one),
        :Kids => node.children.first.children.map { |child| child.ref } }
    )
  end
end
