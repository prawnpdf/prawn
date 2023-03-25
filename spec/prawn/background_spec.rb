# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

describe Prawn::Background do
  let(:filename) { "#{Prawn::DATADIR}/images/pigs.jpg" }
  let(:background) { Prawn::Background.new(background: filename) }
  let(:background_no_enabled) { Prawn::Background.new(background: filename, background_enabled: false) }
  let(:background_no_file) { Prawn::Background.new() }

  # describe '.new' do
  #   it 'does not modify its argument' do
  #     options = { page_layout: :landscape }
  #     described_class.new(options)
  #     expect(options).to eq(page_layout: :landscape)
  #   end
  # end

  describe "#disable" do
    it "disable pdf render" do
      expect(background.render?).to eq(true)
      background.disable
      expect(background.render?).to eq(false)
    end
  end

  describe "#enable" do
    it "enable pdf render" do
      expect(background_no_enabled.render?).to eq(false)
      background_no_enabled.enable
      expect(background_no_enabled.render?).to eq(true)
    end
  end

  describe "#file" do
    it "returns file" do
      expect(background.file).to eq(filename)
      expect(background_no_enabled.file).to eq(filename)
      expect(background_no_file.file).to eq(nil)
    end
  end

  describe "#render?" do
    it "check if render background" do
      expect(background.render?).to eq(true)
      expect(background_no_enabled.render?).to eq(false)
      expect(background_no_file.render?).to eq(false)
    end
  end

  describe "#options" do
    let(:background_fit) { Prawn::Background.new(background: filename, background_dimensions: :fit, page_size: "A4") }

    it "return render options" do
      expect(background.options).to eq({:at=>nil, :scale=>1})
      expect(background_no_enabled.options).to eq({:at=>nil, :scale=>1})
      expect(background_no_file.options).to eq({:at=>nil, :scale=>1})
      expect(background_fit.options).to eq({:at=>nil, :fit=>[595.28, 841.89]})
    end
  end

  describe "#update" do
    it "return render options" do
      background.update(at: [0.0, 0.0], layout: :landscape)
      expect(background.options).to eq({:at=>[0.0, 0.0], :scale=>1})
    end
  end
end