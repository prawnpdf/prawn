# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Prawn::Text::ArabicShaping do
  describe '.contains_arabic?' do
    it 'returns true for Arabic text' do
      expect(described_class.contains_arabic?('مرحبا')).to be true
    end

    it 'returns false for Latin text' do
      expect(described_class.contains_arabic?('Hello')).to be false
    end

    it 'returns true for mixed Arabic/Latin text' do
      expect(described_class.contains_arabic?('Hello مرحبا')).to be true
    end

    it 'returns false for empty string' do
      expect(described_class.contains_arabic?('')).to be false
    end
  end

  describe '.shape' do
    it 'returns nil/empty unchanged' do
      expect(described_class.shape(nil)).to be_nil
      expect(described_class.shape('')).to eq('')
    end

    it 'returns non-Arabic text unchanged' do
      expect(described_class.shape('Hello World')).to eq('Hello World')
    end

    it 'converts Arabic characters to presentation forms' do
      shaped = described_class.shape('مرحبا')
      # All characters should be in the Arabic Presentation Forms range
      shaped.codepoints.each do |cp|
        expect(cp).to be_between(0xFE70, 0xFEFF)
          .or be_between(0xFB50, 0xFDFF)
      end
    end

    it 'shapes initial form correctly' do
      # م at the start of مرحبا should be initial form (FEE3)
      shaped = described_class.shape('مرحبا')
      expect(shaped.codepoints.first).to eq(0xFEE3) # MEEM INITIAL
    end

    it 'shapes final form correctly' do
      # ا at the end of مرحبا should be final form (FE8E)
      shaped = described_class.shape('مرحبا')
      expect(shaped.codepoints.last).to eq(0xFE8E) # ALEF FINAL (via ALEF MAKSURA)
    end

    it 'shapes medial form correctly' do
      # ح in مرحبا should be medial form (FEA4)
      shaped = described_class.shape('مرحبا')
      expect(shaped.codepoints[2]).to eq(0xFEA3) # HAH MEDIAL
    end

    it 'shapes isolated characters correctly' do
      shaped = described_class.shape('ء') # HAMZA - always isolated
      expect(shaped.codepoints.first).to eq(0xFE80)
    end

    it 'handles right-joining characters (Alef, Dal, etc.)' do
      # Alef only joins to the right
      shaped = described_class.shape('با') # BEH + ALEF
      cps = shaped.codepoints
      expect(cps[0]).to eq(0xFE91) # BEH INITIAL
      expect(cps[1]).to eq(0xFE8E) # ALEF FINAL
    end

    it 'creates Lam-Alef ligatures' do
      shaped = described_class.shape('لا')
      expect(shaped.codepoints).to eq([0xFEFB]) # LAM-ALEF ISOLATED
    end

    it 'creates Lam-Alef ligature in final form when preceded' do
      shaped = described_class.shape('بلا') # BEH + LAM + ALEF
      cps = shaped.codepoints
      expect(cps[0]).to eq(0xFE91) # BEH INITIAL
      expect(cps[1]).to eq(0xFEFC) # LAM-ALEF FINAL
    end

    it 'creates Lam-Alef with Madda ligature' do
      shaped = described_class.shape("ل\u0622") # LAM + ALEF WITH MADDA
      expect(shaped.codepoints).to eq([0xFEF5])
    end

    it 'preserves diacritical marks' do
      text = "بِسْمِ" # with kasra and sukun
      shaped = described_class.shape(text)
      # Marks should still be present
      marks = shaped.codepoints.select { |cp| (0x064B..0x065F).cover?(cp) }
      expect(marks).not_to be_empty
    end

    it 'preserves spaces between words' do
      shaped = described_class.shape('مرحبا بالعالم')
      expect(shaped).to include(' ')
    end

    it 'handles mixed Arabic and Latin text' do
      shaped = described_class.shape('Hello مرحبا World')
      expect(shaped).to include('Hello')
      expect(shaped).to include('World')
      # Arabic part should be shaped
      expect(shaped).not_to include('م') # original meem should be replaced
    end

    it 'handles Tatweel (kashida)' do
      shaped = described_class.shape("بـا") # BEH + TATWEEL + ALEF
      cps = shaped.codepoints
      expect(cps).to include(0x0640) # TATWEEL preserved
    end

    it 'shapes Farsi Yeh correctly' do
      shaped = described_class.shape("\u06CC") # FARSI YEH isolated
      expect(shaped.codepoints.first).to eq(0xFBFC) # FARSI YEH ISOLATED
    end

    it 'shapes Peh correctly (Urdu/Farsi)' do
      shaped = described_class.shape("\u067E") # PEH isolated
      expect(shaped.codepoints.first).to eq(0xFB56) # PEH ISOLATED
    end

    it 'shapes Gaf correctly (Farsi)' do
      shaped = described_class.shape("\u06AF") # GAF isolated
      expect(shaped.codepoints.first).to eq(0xFB92) # GAF ISOLATED
    end
  end
end
