# frozen_string_literal: true

require 'spec_helper'
require 'pathname'

describe Prawn::Fonts::ToUnicodeCMap do
  it 'generates a cmap' do
    charmap = {
      0x20 => 0x20,
      0x21 => 0x21,
      0x22 => 0x22,
      0x30 => 0x30
    }
    to_unicode_cmap = described_class.new(charmap)

    expect(to_unicode_cmap.generate).to eq(<<~CMAP.chomp)
      /CIDInit /ProcSet findresource begin
      12 dict begin
      begincmap
      /CIDSystemInfo 3 dict dup begin
        /Registry (Adobe) def
        /Ordering (UCS) def
        /Supplement 0 def
      end def
      /CMapName /Adobe-Identity-UCS def
      /CMapType 2 def
      1 begincodespacerange
      <00><30>
      endcodespacerange
      1 beginbfrange
      <20><22><0020>
      endbfrange
      1 beginbfchar
      <30><0030>
      endbfchar
      endcmap
      CMapName currentdict /CMap defineresource pop
      end
      end
    CMAP
  end

  it 'generates type 2 cmap' do
    cmap = described_class.new(0x20 => 0x30).generate

    expect(cmap).to match(%r{/CMapType 2\b})
  end

  it 'properly sets codespace range' do
    cmap = described_class.new(0x20 => 0x30).generate

    expect(cmap).to include("begincodespacerange\n<00><20>\n")
  end

  it 'properly sets large codespace range' do
    cmap = described_class.new(0x2000 => 0x30).generate

    expect(cmap).to include("begincodespacerange\n<0000><20FF>\n")
  end

  it 'uses codespace size override' do
    cmap = described_class.new({ 0x20 => 0x30 }, 2).generate

    expect(cmap).to include("begincodespacerange\n<0000><0020>\n")
  end

  it 'uses ranges for continuous mappings' do
    cmap = described_class.new(0x20 => 0x30, 0x21 => 0x31, 0x22 => 0x32).generate

    expect(cmap).to include("beginbfrange\n<20><22><0030>\n")
  end

  it 'uses ranges for continuous code rnages with non-continuous mappings' do
    cmap = described_class.new(0x20 => 0x32, 0x21 => 0x31, 0x22 => 0x30).generate

    expect(cmap).to include("beginbfrange\n<20><22>[<0032><0031><0030>]\n")
  end

  it 'uses individual mappings' do
    cmap = described_class.new(0x20 => 0x30, 0x21 => 0x31, 0x22 => 0x32, 0x30 => 0x40).generate

    expect(cmap).to include("beginbfchar\n<30><0040>\n")
  end

  it 'splits continuous mappings into groups of 100' do
    mapping = (1..142).flat_map { |n| Array.new(3) { |i| [n * 10 + i, n * 10 + i] } }.to_h
    cmap = described_class.new(mapping).generate

    expect(cmap).to include("\n100 beginbfrange\n").and include("\n42 beginbfrange\n")
  end

  it 'splits individual mappings into groups of 100' do
    mapping = (1..142).to_h { |n| [n * 2, n * 2] }
    cmap = described_class.new(mapping).generate

    expect(cmap).to include("\n100 beginbfchar\n").and include("\n42 beginbfchar\n")
  end
end
