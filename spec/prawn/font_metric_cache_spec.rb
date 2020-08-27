# frozen_string_literal: true

require 'spec_helper'
require 'pathname'

describe Prawn::FontMetricCache do
  let(:document) { Prawn::Document.new }
  let(:font_metric_cache) { described_class.new(document) }

  it 'starts with an empty cache' do
    expect(font_metric_cache.instance_variable_get(:@cache)).to be_empty
  end

  it 'caches the width of the provided string' do
    font_metric_cache.width_of('M', {})

    expect(font_metric_cache.instance_variable_get(:@cache).size).to eq(1)
  end

  it 'onlies cache a single copy of the same string' do
    font_metric_cache.width_of('M', {})
    font_metric_cache.width_of('M', {})

    expect(font_metric_cache.instance_variable_get(:@cache).size).to eq(1)
  end

  it 'caches different copies for different strings' do
    font_metric_cache.width_of('M', {})
    font_metric_cache.width_of('W', {})

    expect(font_metric_cache.instance_variable_get(:@cache).entries.size)
      .to eq 2
  end

  it 'caches different copies of the same string with different font sizes' do
    font_metric_cache.width_of('M', {})

    document.font_size 24
    font_metric_cache.width_of('M', {})

    expect(font_metric_cache.instance_variable_get(:@cache).entries.size)
      .to eq 2
  end

  it 'caches different copies of the same string with different fonts' do
    font_metric_cache.width_of('M', {})

    document.font 'Courier'
    font_metric_cache.width_of('M', {})

    expect(font_metric_cache.instance_variable_get(:@cache).entries.size)
      .to eq 2
  end

  it 'does not use the cached width of a different font size' do
    pdf = Prawn::Document.new do
      font('Helvetica', size: 42, style: :bold) do
        text 'First part M'
      end
      font('Helvetica', size: 12) do
        text '<strong>First part M</strong> second part', inline_format: true
        text '<strong>First part W</strong> second part.', inline_format: true
      end
    end

    x_positions = PDF::Inspector::Text.analyze(pdf.render).positions.map(&:first)

    expect(x_positions[2]).to be_within(3.0).of(x_positions[4])
  end
end
