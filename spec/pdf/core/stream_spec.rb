# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PDF::Core::Stream do
  subject(:stream) { described_class.new }

  it 'compresses a stream upon request' do
    stream << 'Hi There ' * 20

    cstream = described_class.new
    cstream << 'Hi There ' * 20
    cstream.compress!

    expect(cstream.filtered_stream.length).to be < stream.length
    expect(cstream.data[:Filter]).to eq [:FlateDecode]
  end

  it 'exposes compression state' do
    stream << 'Hello'
    stream.compress!

    expect(stream).to be_compressed
  end

  it 'detects from filters if stream is compressed' do
    stream << 'Hello'
    stream.filters << :FlateDecode

    expect(stream).to be_compressed
  end

  it 'has Length if in data' do
    stream << 'hello'

    expect(stream.data[:Length]).to eq 5
  end

  it 'updates Length when updated' do
    stream << 'hello'
    expect(stream.data[:Length]).to eq 5

    stream << ' world'
    expect(stream.data[:Length]).to eq 11
  end

  it 'corecly handles decode params' do
    stream << 'Hello'
    stream.filters << { FlateDecode: { Predictor: 15 } }

    expect(stream.data[:DecodeParms]).to eq [Predictor: 15]
  end
end
