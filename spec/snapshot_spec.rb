# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn::Document#transaction" do

  it "should properly commit if no error is raised" do
    pdf = Prawn::Document.new do
      transaction do
        text "This is shown"
      end
    end
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.should == ["This is shown"]
  end

  it "should not display text if transaction is rolled back" do
    pdf = Prawn::Document.new do
      transaction do
        text "This is not shown"
        rollback
      end
    end
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.should == []
  end 

  it "should support nested transactions" do
    pdf = Prawn::Document.new do
      transaction do
        text "This is shown"
        transaction do
          text "and this is not"
          rollback
        end
        text "and this is"
      end
    end
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.should == ["This is shown", "and this is"]
  end

  it "should allow rollback of multiple pages" do
    pdf = Prawn::Document.new do
      transaction do
        5.times { start_new_page }
        text "way out there and will never be shown"
        rollback
      end
      text "This is the real text, only one page"
    end

    pages = PDF::Inspector::Page.analyze(pdf.render).pages
    pages.size.should == 1
  end

end

  
