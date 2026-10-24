# frozen_string_literal: true

require 'spec_helper'

describe Prawn::Tagging do
  let(:pdf) { Prawn::Document.new(tagged: true, margin: 0) }

  def reader
    @reader ||= PDF::Reader.new(StringIO.new(pdf.render))
  end

  # Structure tree as nested arrays: an element is `[type, *kids]`, marked
  # content is the number of the page it is on, an annotation is `:annotation`.
  def structure
    objects = reader.objects
    pages = objects.page_references.map(&:id)
    walk =
      lambda do |node|
        node = objects.deref(node)
        case node[:Type]
        when :MCR then pages.index(node[:Pg].id) + 1
        when :OBJR then :annotation
        else [node[:S], *objects.deref(node[:K]).map(&walk)]
        end
      end
    catalog = objects.deref(objects.trailer[:Root])
    objects.deref(objects.deref(catalog[:StructTreeRoot])[:K]).map(&walk)
  end

  def marked_content(page_number)
    reader.page(page_number).raw_content.scan(%r{/(\w+)(?: <<.*?>>)? B[DM]C\n(.*?)EMC}m)
  end

  it 'leaves untagged documents unchanged' do
    untagged = Prawn::Document.new
    untagged.structure(:P) { untagged.text('Hello') }
    untagged.artifact { untagged.stroke_horizontal_rule }
    objects = PDF::Reader.new(StringIO.new(untagged.render)).objects

    expect(untagged).to_not be_tagged
    expect(objects.deref(objects.trailer[:Root]).keys).to_not include(:MarkInfo, :StructTreeRoot)
  end

  it 'sets the document language' do
    pdf = Prawn::Document.new(language: 'pl-PL')

    expect(pdf.state.store.root.data[:Lang]).to eq('pl-PL')
  end

  it 'tags content drawn in a structure element' do
    pdf.structure(:H1) { pdf.text('Title') }
    pdf.structure(:P) { pdf.text('Body') }

    expect(structure).to eq([[:H1, 1], [:P, 1]])
    expect(marked_content(1).map(&:first)).to eq(%w[H1 P])
  end

  it 'nests structure elements' do
    pdf.structure(:L) do
      pdf.structure(:LI) { pdf.text('One') }
      pdf.structure(:LI) { pdf.text('Two') }
    end

    expect(structure).to eq([[:L, [:LI, 1], [:LI, 1]]])
  end

  it 'continues an element over a page break' do
    pdf.structure(:P) { pdf.text('Long paragraph. ' * 400) }

    expect(pdf.page_count).to eq(2)
    expect(structure).to eq([[:P, 1, 2]])
    expect(marked_content(2).first).to match(['P', /TJ/])
  end

  it 'marks artifacts' do
    pdf.artifact(Type: :Layout) { pdf.stroke_horizontal_rule }

    expect(structure).to eq([])
    expect(reader.page(1).raw_content).to include("/Artifact << /Type /Layout\n>> BDC")
  end

  it 'marks repeaters and page numbers as pagination artifacts' do
    pdf.structure(:P) { pdf.text('Body') }
    pdf.repeat(:all) { pdf.draw_text('Footer', at: [0, 0]) }
    pdf.repeat(:all, dynamic: true) { pdf.draw_text(pdf.page_number.to_s, at: [0, 10]) }
    pdf.number_pages('<page>', at: [0, 20])

    expect(structure).to eq([[:P, 1]])
    expect(marked_content(1).map(&:first)).to eq(%w[P Artifact Artifact Artifact])
  end

  it 'marks content drawn on page creation as artifacts' do
    pdf = Prawn::Document.new(tagged: true, background: "#{Prawn::DATADIR}/images/pigs.jpg")
    pdf.state.on_page_create_callback = ->(doc) { doc.draw_text('Header', at: [0, 0]) }
    pdf.structure(:P) do
      pdf.text('First page')
      pdf.start_new_page
      pdf.text('Second page')
    end
    reader = PDF::Reader.new(StringIO.new(pdf.render))

    expect(reader.page(2).raw_content.scan(%r{/(\w+) <<}).flatten).to eq(%w[Artifact Artifact P])
  end

  it 'tags links as Link elements' do
    pdf.structure(:P) do
      pdf.text("Read <link href='https://example.com'>the guide</link>.", inline_format: true)
    end

    expect(structure).to eq([[:P, 1, [:Link, 1, :annotation], 1]])
    annotation = reader.objects.deref(reader.page(1).attributes[:Annots].first)
    expect(annotation[:Contents]).to eq(utf16('the guide'))
    expect(reader.page(1).attributes[:Tabs]).to eq(:S)
  end

  it 'marks stamps where they are drawn' do
    pdf.create_stamp('logo') { pdf.fill_circle([10, 10], 5) }
    pdf.structure(:Figure, Alt: 'Logo') { pdf.stamp('logo') }

    expect(structure).to eq([[:Figure, 1]])
    expect(marked_content(1)).to eq([['Figure', "/Stamp1 Do\n"]])
  end

  it 'balances marked-content operators on every page' do
    pdf.structure(:P) { pdf.text('Long paragraph. ' * 400) }
    pdf.repeat(:all) { pdf.draw_text('Footer', at: [0, 0]) }

    reader.pages.each do |page|
      content = page.raw_content
      expect(content.scan(/B[DM]C$/).size).to eq(content.scan(/^EMC$/).size)
    end
  end

  def utf16(string)
    "\xFE\xFF".b + string.encode('UTF-16BE').b
  end
end
