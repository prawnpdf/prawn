# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")      

describe "when building a text layout" do     

  before(:each) { create_pdf }

  it "should understand common tags by default" do
    layout = new_layout("<b>hi</b> <i>there</i>")
    assert_nothing_raised { lines(layout) }
  end

  private

    def new_layout(text, opts={})
      Prawn::Formatter::LayoutBuilder.new(@pdf, text, opts)
    end

    def lines(layout)
      lines = []
      while (line = layout.next)
        lines << line
      end
      return lines
    end
end
