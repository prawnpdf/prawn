# frozen_string_literal: true

require 'spec_helper'

describe Prawn::View do
  let(:view_object) { Object.new.tap { |o| o.extend(described_class) } }

  it 'provides a Prawn::Document object by default' do
    expect(view_object.document).to be_a(Prawn::Document)
  end

  it 'delegates unhandled methods to object returned by document method' do
    doc = instance_double(Prawn::Document)
    allow(view_object).to receive(:document).and_return(doc)
    allow(doc).to receive(:fill_gradient)
    block = proc {}

    view_object.fill_gradient([1, 2], [3, 4], 'ff0000', [0, 0, 0, 1], apply_margin_options: true, &block)

    expect(doc).to have_received(:fill_gradient)
      .with([1, 2], [3, 4], 'ff0000', [0, 0, 0, 1], apply_margin_options: true, &block)
  end

  it 'allows a block-like DSL via the update method' do
    doc = instance_double(Prawn::Document)
    allow(view_object).to receive(:document).and_return(doc)

    allow(doc).to receive(:font)
    allow(doc).to receive(:cap_style)

    view_object.update do
      font
      cap_style
    end
    expect(doc).to have_received(:font)
    expect(doc).to have_received(:cap_style)
  end

  it 'aliases save_as() to document.render_file()' do
    doc = instance_double(Prawn::Document)
    allow(doc).to receive(:render_file)

    allow(view_object).to receive(:document).and_return(doc)

    view_object.save_as('foo.pdf')
    expect(doc).to have_received(:render_file)
  end

  describe '#respond_to?', issue: 1064 do
    subject { view_object.respond_to?(method) }

    context 'when called with an existing method from Prawn::Document' do
      let(:method) { :text }

      it { is_expected.to be_truthy }
    end

    context 'when called with a non-existing method' do
      let(:method) { :non_existing_method }

      it { is_expected.to be_falsey }
    end
  end
end
