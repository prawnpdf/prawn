# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Prawn::Text::ArabicShaping do
  describe '.contains_arabic?' do
    it 'returns true for Arabic text' do
      expect(described_class.contains_arabic?('مرحبا')).to be(true)
    end

    it 'returns false for Latin text' do
      expect(described_class.contains_arabic?('Hello')).to be(false)
    end

    it 'returns true for mixed Arabic/Latin text' do
      expect(described_class.contains_arabic?('Hello مرحبا')).to be(true)
    end

    it 'returns false for empty string' do
      expect(described_class.contains_arabic?('')).to be(false)
    end
  end

  describe '.shape' do
    it 'returns nil unchanged' do
      expect(described_class.shape(nil)).to be_nil
    end

    it 'returns empty string unchanged' do
      expect(described_class.shape('')).to eq('')
    end

    it 'returns non-Arabic text unchanged' do
      expect(described_class.shape('Hello World')).to eq('Hello World')
    end

    it 'converts Arabic characters to presentation forms' do
      shaped = described_class.shape('مرحبا')
      expect(shaped.codepoints).to all(
        be_between(0xFE70, 0xFEFF).or(be_between(0xFB50, 0xFDFF)),
      )
    end

    it 'shapes initial form correctly' do
      shaped = described_class.shape('مرحبا')
      expect(shaped.codepoints.first).to eq(0xFEE3)
    end

    it 'shapes final form correctly' do
      shaped = described_class.shape('مرحبا')
      expect(shaped.codepoints.last).to eq(0xFE8E)
    end

    it 'shapes medial form correctly' do
      shaped = described_class.shape('مرحبا')
      expect(shaped.codepoints[2]).to eq(0xFEA3)
    end

    it 'shapes isolated characters correctly' do
      shaped = described_class.shape('ء')
      expect(shaped.codepoints.first).to eq(0xFE80)
    end

    it 'handles right-joining characters' do
      shaped = described_class.shape('با')
      cps = shaped.codepoints
      expect(cps[0]).to eq(0xFE91)
      expect(cps[1]).to eq(0xFE8E)
    end

    it 'creates Lam-Alef ligatures' do
      shaped = described_class.shape('لا')
      expect(shaped.codepoints).to eq([0xFEFB])
    end

    it 'creates Lam-Alef ligature in final form when preceded' do
      shaped = described_class.shape('بلا')
      cps = shaped.codepoints
      expect(cps[0]).to eq(0xFE91)
      expect(cps[1]).to eq(0xFEFC)
    end

    it 'creates Lam-Alef with Madda ligature' do
      shaped = described_class.shape("\u0644\u0622")
      expect(shaped.codepoints).to eq([0xFEF5])
    end

    it 'preserves diacritical marks' do
      shaped = described_class.shape("\u0628\u0650\u0633\u0652\u0645\u0650")
      marks = shaped.codepoints.select { |codepoint| (0x064B..0x065F).cover?(codepoint) }
      expect(marks).to_not be_empty
    end

    it 'preserves spaces between words' do
      shaped = described_class.shape('مرحبا بالعالم')
      expect(shaped).to include(' ')
    end

    it 'handles mixed Arabic and Latin text' do
      shaped = described_class.shape('Hello مرحبا World')
      expect(shaped).to include('Hello')
      expect(shaped).to include('World')
      expect(shaped).to_not include('م')
    end

    it 'handles Tatweel' do
      shaped = described_class.shape("\u0628\u0640\u0627")
      expect(shaped.codepoints).to include(0x0640)
    end

    it 'shapes Farsi Yeh correctly' do
      shaped = described_class.shape("\u06CC")
      expect(shaped.codepoints.first).to eq(0xFBFC)
    end

    it 'shapes Peh correctly' do
      shaped = described_class.shape("\u067E")
      expect(shaped.codepoints.first).to eq(0xFB56)
    end

    it 'shapes Gaf correctly' do
      shaped = described_class.shape("\u06AF")
      expect(shaped.codepoints.first).to eq(0xFB92)
    end
  end
end
