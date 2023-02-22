# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PDF::Core::DocumentState do
  subject(:state) { described_class.new({}) }

  describe 'initialization' do
    it { expect(state.compress).to eq(false) }
    it { expect(state.encrypt).to eq(false) }
    it { expect(state.skip_encoding).to eq(false) }
    it { expect(state.trailer).to eq({}) }
  end

  describe 'normalize_metadata' do
    it { expect(state.store.info.data[:Creator]).to eq('Prawn') }
    it { expect(state.store.info.data[:Producer]).to eq('Prawn') }
  end

  describe 'given a trailer ID with two values' do
    subject(:state) do
      described_class.new(
        trailer: { ID: %w[myDoc versionA] }
      )
    end

    it 'contains the ID entry with two values in trailer' do
      expect(state.trailer[:ID].count).to eq(2)
    end
  end
end
