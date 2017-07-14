require 'spec_helper'
require_relative 'vera_pdf'

describe Prawn::Document do
  include Prawn::VeraPdf

  let(:pdf) { described_class.new(enable_pdfa_1b: true) }

  describe 'PDF/A 1b conformance' do
    it 'empty document' do
      expect(valid_pdfa_1b?(pdf.render)).to be true
    end

    it 'document with some text' do
      pdf.font_families.update(
        'DejaVuSans' => {
          normal: "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
        }
      )
      pdf.font 'DejaVuSans' do
        pdf.text_box 'Some text', at: [100, 100]
      end
      expect(valid_pdfa_1b?(pdf.render)).to be true
    end

    it 'document with some image' do
      pdf.image "#{Prawn::DATADIR}/images/pigs.jpg"
      expect(valid_pdfa_1b?(pdf.render)).to be true
    end
  end
end
