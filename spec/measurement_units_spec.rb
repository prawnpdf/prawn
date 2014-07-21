# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")
require "prawn/measurement_extensions"

describe "Measurement units" do

  it "should convert units to PostScriptPoints" do
    1.mm.should be_within(0.000000001).of(2.834645669)
    1.mm.should == (72 / 25.4)
    2.mm.should == (2 * 72 / 25.4)
    3.mm.should == 3 * 72 / 25.4
    -3.mm.should == -3 * 72/25.4
    1.cm.should == 10 * 72 / 25.4
    1.dm.should == 100 * 72 / 25.4
    1.m.should == 1000 * 72 / 25.4

    1.in.should == 72
    1.ft.should == 72 * 12
    1.yd.should == 72 * 12 * 3
    1.pt.should == 1
  end

end

