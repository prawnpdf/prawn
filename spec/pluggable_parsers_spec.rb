# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

require "prawn/text/formatted"

describe "pluggable parsers" do
  Formatted = Prawn::Text::Formatted

  context "#register_parser, #unregister_parser, and #find_parser" do
    it "finds registered parsers correctly" do
      Formatted.register_parser(:mock, "mock parser")
      Formatted.find_parser(:mock).should == "mock parser"
      Formatted.unregister_parser(:mock)
      Formatted.find_parser(:mock).should == nil
    end
  end

  context "#invoke_parser" do
    it "calls the parsers to_array method with corect arguments" do
      class TestParser
        def self.to_array(string, *args)
          return [string, args]
        end
      end

      Formatted.register_parser(:mock, TestParser)
      Formatted.invoke_parser(:mock, "string").should == ["string", []]
      Formatted.invoke_parser([:mock], "string").should == ["string", []]
      Formatted.invoke_parser([:mock, "foo"], "string").should == ["string", ["foo"]]
      Formatted.invoke_parser([:mock, "foo", "bar"], "string").should == ["string", ["foo", "bar"]]
      Formatted.unregister_parser(:mock)
    end
  end
end
