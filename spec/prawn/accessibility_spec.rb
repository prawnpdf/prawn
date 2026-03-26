# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Prawn::Accessibility do
  describe 'with tagged document' do
    let(:pdf) { Prawn::Document.new(marked: true, language: 'en-US') }

    describe '#tagged?' do
      it 'returns true for marked documents' do
        expect(pdf).to be_tagged
      end

      it 'returns false for unmarked documents' do
        plain = Prawn::Document.new
        expect(plain).to_not(be_tagged)
      end
    end

    describe 'language' do
      it 'sets Lang on the catalog' do
        root_data = pdf.state.store.root.data
        expect(root_data[:Lang]).to eq('en-US')
      end
    end

    describe '#structure' do
      it 'wraps content in a structure element' do
        pdf.structure(:H1) do
          pdf.text('Title')
        end
        output = pdf.render

        expect(output).to include('/StructTreeRoot')
        expect(output).to include('/StructElem')
      end

      it 'emits BDC/EMC in the content stream' do
        pdf.structure(:P) do
          pdf.text('Hello')
        end
        output = pdf.render

        expect(output).to include('BDC')
        expect(output).to include('EMC')
      end

      it 'is a no-op for untagged documents' do
        plain = Prawn::Document.new
        plain.structure(:P) do
          plain.text('Hello')
        end
        output = plain.render

        expect(output).to_not(include('/StructTreeRoot'))
      end
    end

    describe '#structure_container' do
      it 'creates a parent structure without marking content directly' do
        pdf.structure_container(:Table) do
          pdf.structure(:TD) do
            pdf.text('Cell')
          end
        end
        output = pdf.render

        expect(output).to include('/StructElem')
        expect(output).to include('/Table')
        expect(output).to include('/TD')
      end
    end

    describe '#artifact' do
      it 'wraps content in Artifact markers' do
        pdf.artifact do
          pdf.text('Page 1')
        end
        output = pdf.render

        expect(output).to include('/Artifact BMC')
        expect(output).to include('EMC')
      end

      it 'supports artifact type' do
        pdf.artifact(type: :Pagination) do
          pdf.text('Page 1')
        end
        output = pdf.render

        expect(output).to include('/Artifact')
        expect(output).to include('/Type /Pagination')
      end

      it 'is a no-op for untagged documents' do
        plain = Prawn::Document.new
        plain.artifact do
          plain.text('Footer')
        end
        output = plain.render

        expect(output).to_not(include('/Artifact'))
      end
    end

    describe '#heading' do
      it 'renders text in an H1 structure element' do
        pdf.heading(1, 'Title', size: 24)
        output = pdf.render

        expect(output).to include('/H1')
        expect(output).to include('BDC')
      end

      it 'supports levels 1-6' do
        (1..6).each do |level|
          pdf.heading(level, "Heading #{level}")
        end
        output = pdf.render

        (1..6).each do |level|
          expect(output).to include("/H#{level}")
        end
      end
    end

    describe '#paragraph' do
      it 'renders text in a P structure element' do
        pdf.paragraph('Body text.')
        output = pdf.render

        expect(output).to include('BDC')
      end

      it 'supports block form' do
        pdf.paragraph do
          pdf.text('Complex paragraph')
        end
        output = pdf.render

        expect(output).to include('BDC')
        expect(output).to include('EMC')
      end
    end

    describe 'ActualText' do
      it 'passes ActualText to structure elements' do
        pdf.structure(:Span, ActualText: 'required') do
          pdf.text('*')
        end
        output = pdf.render

        expect(output).to include('/ActualText')
      end

      it 'allows ActualText for checkbox indicators' do
        pdf.structure(:Span, ActualText: 'Selected') do
          pdf.text('X')
        end
        pdf.structure(:Span, ActualText: 'Not selected') do
          pdf.text(' ')
        end
        output = pdf.render

        expect(output).to include('/ActualText')
      end
    end

    describe '#figure' do
      it 'wraps content with alt text' do
        pdf.figure(alt_text: 'A logo') do
          pdf.text('IMAGE PLACEHOLDER')
        end
        output = pdf.render

        expect(output).to include('/Figure')
        expect(output).to include('/Alt')
      end
    end

    describe 'full document round-trip' do
      it 'produces a tagged PDF with MarkInfo and StructTreeRoot' do
        pdf.heading(1, 'Test Document')
        pdf.paragraph('This is a test paragraph.')

        pdf.artifact(type: :Pagination) do
          pdf.text('Page 1 of 1')
        end

        output = pdf.render

        expect(output).to start_with('%PDF-1.7')
        expect(output).to include('/MarkInfo')
        expect(output).to include('/Marked true')
        expect(output).to include('/StructTreeRoot')
        expect(output).to include('/Lang')
        expect(output).to include('/Document')
      end
    end
  end
end
