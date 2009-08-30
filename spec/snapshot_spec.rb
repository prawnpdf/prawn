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

  it "should not display text if RollbackTransaction is raised" do
    pdf = Prawn::Document.new do
      transaction do
        text "This is not shown"
        raise Prawn::Document::RollbackTransaction
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
          raise Prawn::Document::RollbackTransaction
        end
        text "and this is"
      end
    end
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.should == ["This is shown", "and this is"]
  end

end

  
