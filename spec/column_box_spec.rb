# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A column box" do
  it "has sensible left and right values" do
    create_pdf
    @pdf.column_box [0, @pdf.cursor], :width => @pdf.bounds.width,
      :height => 200, :columns => 3, :spacer => 25 do
        left = @pdf.bounds.left
        right = @pdf.bounds.right

        @pdf.bounds.move_past_bottom # next column

        @pdf.bounds.left.should be > left
        @pdf.bounds.left.should be > right
        @pdf.bounds.right.should be > @pdf.bounds.left
      end
  end

  it "includes spacers between columns but not at the end" do
    create_pdf
    @pdf.column_box [0, @pdf.cursor], :width => 500,
      :height => 200, :columns => 3, :spacer => 25 do
        @pdf.bounds.width.should == 150 # (500 - (25 * 2)) / 3

        @pdf.bounds.move_past_bottom
        @pdf.bounds.move_past_bottom

        @pdf.bounds.right.should == 500
      end
  end

  it "does not reset the top margin on a new page by default" do
    create_pdf
    page_top = @pdf.cursor
    @pdf.move_down 50
    init_column_top = @pdf.cursor
    @pdf.column_box [0, @pdf.cursor], :width => 500,
      :height => 200, :columns => 2 do

        @pdf.bounds.move_past_bottom
        @pdf.bounds.move_past_bottom

        @pdf.bounds.absolute_top.should == init_column_top
        @pdf.bounds.absolute_top.should_not == page_top
      end
  end

  it "does reset the top margin when reflow_margins is set" do
    create_pdf
    page_top = @pdf.cursor
    @pdf.move_down 50
    init_column_top = @pdf.cursor
    @pdf.column_box [0, @pdf.cursor], :width => 500, :reflow_margins => true,
      :height => 200, :columns => 2 do

        @pdf.bounds.move_past_bottom
        @pdf.bounds.move_past_bottom

        @pdf.bounds.absolute_top.should == page_top
        @pdf.bounds.absolute_top.should_not == init_column_top
      end
  end
end
