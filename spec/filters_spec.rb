# frozen_string_literal: true

require_relative 'spec_helper'

FILTERS = {
  FlateDecode: {
    'test' => (+"x\x9C+I-.\x01\x00\x04]\x01\xC1").force_encoding(Encoding::ASCII_8BIT)
  },
  DCTDecode: { 'test' => 'test' }
}.freeze

FILTERS.each do |filter_name, examples|
  filter = PDF::Core::Filters.const_get(filter_name)

  RSpec.describe "#{filter_name} filter" do
    it 'encodes stream' do
      examples.each do |in_stream, out_stream|
        expect(filter.encode(in_stream)).to eq out_stream
      end
    end

    it 'decodes stream' do
      examples.each do |in_stream, out_stream|
        expect(filter.decode(out_stream)).to eq in_stream
      end
    end

    it 'is symmetric' do
      examples.each do |in_stream, out_stream|
        expect(filter.decode(filter.encode(in_stream))).to eq in_stream

        expect(filter.encode(filter.decode(out_stream))).to eq out_stream
      end
    end
  end
end
