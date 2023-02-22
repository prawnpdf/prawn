# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PDF::Core::NameTree do
  def tree_dump(tree)
    if tree.is_a?(PDF::Core::NameTree::Node)
      "[#{tree.children.map { |child| tree_dump(child) }.join(',')}]"
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
    PDF::Core::NameTree::Value.new(name, value)
  end

  let(:pdf) do
    document_class =
      Class.new do
        def initialize
          @object_store = []
        end

        attr_reader :object_store

        def ref!(obj)
          @object_store << obj
        end
      end
    document_class.new
  end

  it 'has no children when first initialized' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    expect(node.children.length).to eq 0
  end

  it 'has no subtrees while child limit is not reached' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3])
    expect(tree_dump(node)).to eq '[one=1,three=3,two=2]'
  end

  it 'splits into subtrees when limit is exceeded' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3], ['four', 4])
    expect(tree_dump(node)).to eq '[[four=4,one=1],[three=3,two=2]]'
  end

  it 'creates a two new references when root is split' do
    ref_count = pdf.object_store.length
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3], ['four', 4])
    expect(pdf.object_store.length).to eq ref_count + 2
  end

  it 'creates a one new reference when subtree is split' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3], ['four', 4])

    ref_count = pdf.object_store.length # save when root is split
    tree_add(node, ['five', 5], ['six', 6], ['seven', 7])
    expect(tree_dump(node)).to eq(
      '[[five=5,four=4,one=1],[seven=7,six=6],[three=3,two=2]]'
    )
    expect(pdf.object_store.length).to eq ref_count + 1
  end

  it 'keeps tree balanced when subtree split cascades to root' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3], ['four', 4])
    tree_add(node, ['five', 5], ['six', 6], ['seven', 7], ['eight', 8])
    expect(tree_dump(node)).to eq(
      '[[[eight=8,five=5],[four=4,one=1]],[[seven=7,six=6],[three=3,two=2]]]'
    )
  end

  it 'maintains order of already properly ordered nodes' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['eight', 8], ['five', 5], ['four', 4], ['one', 1])
    tree_add(node, ['seven', 7], ['six', 6], ['three', 3], ['two', 2])
    expect(tree_dump(node)).to eq(
      '[[[eight=8,five=5],[four=4,one=1]],[[seven=7,six=6],[three=3,two=2]]]'
    )
  end

  it 'emits only :Names key with to_hash if root is only node' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3])
    expect(node.to_hash).to eq(
      Names: [
        tree_value('one', 1), tree_value('three', 3), tree_value('two', 2)
      ]
    )
  end

  it 'emits only :Kids key with to_hash if root has children' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3], ['four', 4])
    expect(node.to_hash).to eq Kids: node.children.map(&:ref)
  end

  it 'emits :Limits and :Names keys with to_hash for leaf node' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3], ['four', 4])
    expect(node.children.first.to_hash).to eq(
      Limits: %w[four one],
      Names: [tree_value('four', 4), tree_value('one', 1)]
    )
  end

  it 'emits :Limits and :Kids keys with to_hash for inner node' do
    node = PDF::Core::NameTree::Node.new(pdf, 3)
    tree_add(node, ['one', 1], ['two', 2], ['three', 3], ['four', 4])
    tree_add(node, ['five', 5], ['six', 6], ['seven', 7], ['eight', 8])
    tree_add(node, ['nine', 9], ['ten', 10], ['eleven', 11], ['twelve', 12])
    tree_add(
      node, ['thirteen', 13], ['fourteen', 14], ['fifteen', 15], ['sixteen', 16]
    )
    expect(node.children.first.to_hash).to eq(
      Limits: %w[eight one],
      Kids: node.children.first.children.map(&:ref)
    )
  end
end
