# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")
require 'pathname'

describe "Font metrics caching" do
  let(:document) { Prawn::Document.new }

  subject { Prawn::FontMetricCache.new( document ) }

  it "should start with an empty cache" do
    subject.instance_variable_get( :@cache ).should be_empty
  end

  it "should cache the width of the provided string" do
    subject.width_of('M', {})

    subject.instance_variable_get( :@cache ).should have(1).entry
  end

  it "should only cache a single copy of the same string" do
    subject.width_of('M', {})
    subject.width_of('M', {})

    subject.instance_variable_get( :@cache ).should have(1).entry
  end

  it "should cache different copies for different strings" do
    subject.width_of('M', {})
    subject.width_of('W', {})

    subject.instance_variable_get( :@cache ).should have(2).entries
  end

  it "should cache different copies of the same string with different font sizes" do
    subject.width_of('M', {})

    document.font_size 24
    subject.width_of('M', {})

    subject.instance_variable_get( :@cache ).should have(2).entries
  end

  it "should cache different copies of the same string with different fonts" do
    subject.width_of('M', {})

    document.font 'Courier'
    subject.width_of('M', {})

    subject.instance_variable_get( :@cache ).should have(2).entries
  end
end
