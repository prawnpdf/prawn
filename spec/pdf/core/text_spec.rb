# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PDF::Core::Text do
  let(:mock) do
    text_mock_class =
      Class.new do
        include PDF::Core::Text

        attr_reader :text

        def add_content(str)
          @text ||= +''
          @text << str
        end

        def font
          @font ||= Class.new do
            def encode_text(text, _options)
              [nil, text]
            end

            def add_to_current_page(_subset); end

            def identifier_for(_subset)
              :Font
            end
          end.new
        end

        def font_size
          12
        end
      end
    text_mock_class.new
  end

  describe '#text_rendering_mode' do
    describe 'called without argument' do
      let(:result) { mock.text_rendering_mode }

      it 'functions as accessor' do
        expect(result).to eq(:fill)
      end
    end

    describe 'called with argument' do
      context 'when the block does not raise an error' do
        before do
          mock.text_rendering_mode(:fill_stroke) do
            mock.add_content('TEST')
          end
        end

        it 'resets text_rendering_mode to original value' do
          expect(mock.text_rendering_mode).to eq(:fill)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n2 TrTEST\n0 Tr")
        end
      end

      context 'when the block raises an error' do
        let(:error_message) { SecureRandom.hex(5) }

        # rubocop:disable RSpec/ExpectInHook
        before do
          expect do
            mock.text_rendering_mode(:fill_stroke) do
              raise StandardError, error_message
            end
          end.to raise_error StandardError, error_message
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'resets text_rendering_mode to original value' do
          expect(mock.text_rendering_mode).to eq(:fill)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n2 Tr\n0 Tr")
        end
      end
    end
  end

  describe '#horizontal_text_scaling' do
    describe 'called without argument' do
      let(:result) { mock.horizontal_text_scaling }

      it 'functions as accessor' do
        expect(result).to eq(100)
      end
    end

    describe 'called with argument' do
      context 'when the block does not raise an error' do
        before do
          mock.horizontal_text_scaling(110) do
            mock.add_content('TEST')
          end
        end

        it 'resets horizontal_text_scaling to original value' do
          expect(mock.horizontal_text_scaling).to eq(100)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n110.0 TzTEST\n100.0 Tz")
        end
      end

      context 'when the block raises an error' do
        let(:error_message) { SecureRandom.hex(5) }

        # rubocop:disable RSpec/ExpectInHook
        before do
          expect do
            mock.horizontal_text_scaling(110) do
              raise StandardError, error_message
            end
          end.to raise_error StandardError, error_message
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'resets horizontal_text_scaling to original value' do
          expect(mock.horizontal_text_scaling).to eq(100)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n110.0 Tz\n100.0 Tz")
        end
      end
    end
  end

  describe '#character_spacing' do
    describe 'called without argument' do
      let(:result) { mock.character_spacing }

      it 'functions as accessor' do
        expect(result).to eq(0)
      end
    end

    describe 'called with argument' do
      context 'when the block does not raise an error' do
        before do
          mock.character_spacing(10) do
            mock.add_content('TEST')
          end
        end

        it 'resets character_spacing to original value' do
          expect(mock.character_spacing).to eq(0)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n10.0 TcTEST\n0.0 Tc")
        end
      end

      context 'when the block raises an error' do
        let(:error_message) { SecureRandom.hex(5) }

        # rubocop:disable RSpec/ExpectInHook
        before do
          expect do
            mock.character_spacing(10) do
              raise StandardError, error_message
            end
          end.to raise_error StandardError, error_message
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'resets character_spacing to original value' do
          expect(mock.character_spacing).to eq(0)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n10.0 Tc\n0.0 Tc")
        end
      end
    end
  end

  describe '#word_spacing' do
    describe 'called without argument' do
      let(:result) { mock.word_spacing }

      it 'functions as accessor' do
        expect(result).to eq(0)
      end
    end

    describe 'called with argument' do
      context 'when the block does not raise an error' do
        before do
          mock.word_spacing(10) do
            mock.add_content('TEST')
          end
        end

        it 'resets word_spacing to original value' do
          expect(mock.word_spacing).to eq(0)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n10.0 TwTEST\n0.0 Tw")
        end
      end

      context 'when the block raises an error' do
        let(:error_message) { SecureRandom.hex(5) }

        # rubocop:disable RSpec/ExpectInHook
        before do
          expect do
            mock.word_spacing(10) do
              raise StandardError, error_message
            end
          end.to raise_error StandardError, error_message
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'resets word_spacing to original value' do
          expect(mock.word_spacing).to eq(0)
        end

        it 'outputs correct PDF content' do
          expect(mock.text).to eq("\n10.0 Tw\n0.0 Tw")
        end
      end
    end
  end

  describe '#add_text_content' do
    it 'handles frozen strings' do
      expect { mock.add_text_content 'text', 0, 0, {} }
        .to_not raise_error
    end
  end
end
