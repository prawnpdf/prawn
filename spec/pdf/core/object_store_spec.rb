# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PDF::Core::ObjectStore do
  subject(:store) { described_class.new }

  it 'creates required roots by default, including info passed to new' do
    store = described_class.new(info: { Test: 3 })
    expect(store.size).to eq 3 # 3 default roots
    expect(store.info.data[:Test]).to eq 3
    expect(store.pages.data[:Count]).to eq 0
    expect(store.root.data[:Pages]).to eq store.pages
  end

  it 'adds to its objects when ref() is called' do
    count = store.size
    store.ref('blah')
    expect(store.size).to eq count + 1
  end

  it 'accepts push with a Prawn::Reference' do
    r = PDF::Core::Reference.new(123, 'blah')
    store.push(r)
    expect(store[r.identifier]).to eq r
  end

  it 'accepts arbitrary data and use it to create a Prawn::Reference' do
    store.push(123, 'blahblah')
    expect(store[123].data).to eq 'blahblah'
  end

  it 'is Enumerable, yielding in order of submission' do
    # higher IDs to bypass the default roots
    [10, 11, 12].each do |id|
      store.push(id, "some data #{id}")
    end
    expect(store.map(&:identifier)[-3..]).to eq [10, 11, 12]
  end

  it 'accepts option to disabling PDF scaling in PDF clients' do
    store = described_class.new(print_scaling: :none)
    expect(store.root.data[:ViewerPreferences]).to eq PrintScaling: :None
  end
end
