# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A bounding box" do

  before(:each) do
    @x      = 100
    @y      = 125
    @width  = 50
    @height = 75
    @box = Prawn::Document::BoundingBox.new(nil, nil, [@x,@y],
      :width  => @width, :height => @height )
  end

  it "should have an anchor at (x, y - height)" do
    @box.anchor.should == [@x,@y-@height]
  end

  it "should have a left boundary of 0" do
    @box.left.should == 0
  end

  it "should have a right boundary equal to the width" do
    @box.right.should == @width
  end

  it "should have a top boundary of height" do
    @box.top.should == @height
  end

  it "should have a bottom boundary of 0" do
    @box.bottom.should == 0
  end

  it "should have a top-left of [0,height]" do
    @box.top_left.should == [0,@height]
  end

  it "should have a top-right of [width,height]" do
    @box.top_right.should == [@width,@height]
  end

  it "should have a bottom-left of [0,0]" do
    @box.bottom_left.should == [0,0]
  end

  it "should have a bottom-right of [width,0]" do
    @box.bottom_right.should == [@width,0]
  end

  it "should have an absolute left boundary of x" do
    @box.absolute_left.should == @x
  end

  it "should have an absolute right boundary of x + width" do
    @box.absolute_right.should == @x + @width
  end

  it "should have an absolute top boundary of y" do
    @box.absolute_top.should == @y
  end

  it "should have an absolute bottom boundary of y - height" do
    @box.absolute_bottom.should == @y - @height
  end

  it "should have an absolute bottom-left of [x,y-height]" do
    @box.absolute_bottom_left.should == [@x, @y - @height]
  end

  it "should have an absolute bottom-right of [x+width,y-height]" do
    @box.absolute_bottom_right.should == [@x + @width , @y - @height]
  end

  it "should have an absolute top-left of [x,y]" do
    @box.absolute_top_left.should == [@x, @y]
  end

  it "should have an absolute top-right of [x+width,y]" do
    @box.absolute_top_right.should == [@x + @width, @y]
  end

  it "should require width to be set" do
    lambda do
      Prawn::Document::BoundingBox.new(nil, nil, [100,100])
    end.should.raise(ArgumentError)
  end

  it "should raise an ArgumentError if a block is not passed" do
    pdf = Prawn::Document.new
    lambda do
      pdf.bounding_box([0, 0], :width => 200)
    end.should.raise(ArgumentError)
  end

end

describe "drawing bounding boxes" do

  before(:each) { create_pdf }

  it "should restore the margin box when bounding box exits" do
    margin_box = @pdf.bounds

    @pdf.bounding_box [100,500], :width => 100 do
      #nothing
    end

    @pdf.bounds.should == margin_box

  end

  it "should restore the parent bounding box when calls are nested" do
    @pdf.bounding_box [100,500], :width => 300, :height => 300 do

      @pdf.bounds.absolute_top.should  == 500 + @pdf.margin_box.absolute_bottom
      @pdf.bounds.absolute_left.should == 100 + @pdf.margin_box.absolute_left

      parent_box = @pdf.bounds

      @pdf.bounding_box [50,200], :width => 100, :height => 100 do
        @pdf.bounds.absolute_top.should == 200 + parent_box.absolute_bottom
        @pdf.bounds.absolute_left.should == 50 + parent_box.absolute_left
      end

      @pdf.bounds.absolute_top.should  == 500 + @pdf.margin_box.absolute_bottom
      @pdf.bounds.absolute_left.should == 100 + @pdf.margin_box.absolute_left

    end
  end

  it "should calculate a height if none is specified" do
    @pdf.bounding_box([100, 500], :width => 100) do
      @pdf.text "The rain in Spain falls mainly on the plains."
    end

    @pdf.y.should.be.close 458.384, 0.001
  end

  it "should keep track of the max height the box was stretched to" do
    box = @pdf.bounding_box(@pdf.bounds.top_left, :width => 100) do
      @pdf.move_down 100
      @pdf.move_up 15
    end

    box.height.should == 100
  end

  it "should advance the y-position by bbox.height by default" do
    orig_y = @pdf.y
    @pdf.bounding_box [0, @pdf.cursor], :width => @pdf.bounds.width,
        :height => 30 do
      @pdf.text "hello"
    end
    @pdf.y.should.be.close(orig_y - 30, 0.001)
  end

  it "should not advance y-position if passed :hold_position => true" do
    orig_y = @pdf.y
    @pdf.bounding_box [0, @pdf.cursor], :width => @pdf.bounds.width,
        :hold_position => true do
      @pdf.text "hello"
    end
    # y only advances by height of one line ("hello")
    @pdf.y.should.be.close(orig_y - @pdf.height_of("hello"), 0.001)
  end

  it "should not advance y-position of a stretchy bbox if it would stretch " +
     "the bbox further" do
    bottom = @pdf.y = @pdf.margin_box.absolute_bottom
    @pdf.bounding_box [0, @pdf.margin_box.top], :width => @pdf.bounds.width do
      @pdf.y = bottom
      @pdf.text "hello" # starts a new page
    end
    @pdf.page_count.should == 2

    # Restoring the position (to the absolute bottom) would stretch the bbox to
    # the bottom of the page, which we don't want. This should be equivalent to
    # a bbox with :hold_position => true, where we only advance by the amount
    # that was actually drawn.
    @pdf.y.should.be.close(
      @pdf.margin_box.absolute_top - @pdf.height_of("hello"),
      0.001
    )
  end

end

describe "Indentation" do
  before(:each) { create_pdf }

  it "should temporarily shift the x coordinate and width" do
    @pdf.bounding_box([100,100], :width => 200) do
      @pdf.indent(20) do
        @pdf.bounds.absolute_left.should == 120
        @pdf.bounds.width.should == 180
      end
    end
  end

  it "should restore the x coordinate and width after block exits" do
    @pdf.bounding_box([100,100], :width => 200) do
      @pdf.indent(20) do
        # no-op
      end
      @pdf.bounds.absolute_left.should == 100
      @pdf.bounds.width.should == 200
    end
  end

  it "should restore the x coordinate and width on error" do
    @pdf.bounding_box([100,100], :width => 200) do
      begin
        @pdf.indent(20) { raise }
      rescue
        @pdf.bounds.absolute_left.should == 100
        @pdf.bounds.width.should == 200
      end
    end
  end

  it "should maintain left indentation across a page break" do
    original_left = @pdf.bounds.absolute_left

    @pdf.indent(20) do
      @pdf.bounds.absolute_left.should == original_left + 20
      @pdf.start_new_page
      @pdf.bounds.absolute_left.should == original_left + 20
    end

    @pdf.bounds.absolute_left.should == original_left
  end

  it "should maintain right indentation across a page break" do
    original_width = @pdf.bounds.width

    @pdf.indent(0, 20) do
      @pdf.bounds.width.should == original_width - 20
      @pdf.start_new_page
      @pdf.bounds.width.should == original_width - 20
    end

    @pdf.bounds.width.should == original_width
  end

  it "optionally allows adjustment of the right bound as well" do
    @pdf.bounding_box([100,100], :width => 200) do
      @pdf.indent(20, 30) do
        @pdf.bounds.absolute_left.should == 120
        @pdf.bounds.width.should == 150
      end
      @pdf.bounds.absolute_left.should == 100
      @pdf.bounds.width.should == 200
    end
  end

  describe "in a ColumnBox" do
    it "should subtract the given indentation from the available width" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width,
                      :height => 200, :columns => 2, :spacer => 20) do
        width = @pdf.bounds.width
        @pdf.indent(20) do
          @pdf.bounds.width.should.be.close(width - 20, 0.01)
        end
      end
    end

    it "should subtract right padding from the available width" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width,
                      :height => 200, :columns => 2, :spacer => 20) do
        width = @pdf.bounds.width
        @pdf.indent(20, 30) do
          @pdf.bounds.width.should.be.close(width - 50, 0.01)
        end
      end
    end

  end
end

describe "A canvas" do
  before(:each) { create_pdf }

  it "should use whatever the last set y position is" do
    @pdf.canvas do
      @pdf.bounding_box([100,500],:width => 200) { @pdf.move_down 50 }
    end
    @pdf.y.should == 450
  end
end

describe "Deep-copying" do
  it "should create a new object that does not copy @document" do
    Prawn::Document.new do
      orig = bounds
      copy = orig.deep_copy

      copy.should.not == bounds
      copy.document.should.be.nil
    end
  end

  it "should deep-copy parent bounds" do
    Prawn::Document.new do |pdf|
      outside = pdf.bounds
      pdf.bounding_box [100, 100], :width => 100 do
        copy = pdf.bounds.deep_copy

        # the parent bounds should have the same parameters
        copy.parent.width.should  == outside.width
        copy.parent.height.should == outside.height

        # but should not be the same object
        copy.parent.should.not == outside
      end
    end
  end
end

describe "Prawn::Document#reference_bounds" do
  before(:each) { create_pdf }

  it "should return self for non-stretchy bounds" do
    @pdf.bounding_box([0, @pdf.cursor], :width => 100, :height => 100) do
      @pdf.reference_bounds.should == @pdf.bounds
    end
  end

  it "should return the parent bounds if in a stretchy box" do
    @pdf.bounding_box([0, @pdf.cursor], :width => 100, :height => 100) do
      correct_bounds = @pdf.bounds
      @pdf.bounding_box([0, @pdf.cursor], :width => 100) do
        @pdf.reference_bounds.should == correct_bounds
      end
    end
  end

  it "should find the non-stretchy box through 2 levels" do
    @pdf.bounding_box([0, @pdf.cursor], :width => 100, :height => 100) do
      correct_bounds = @pdf.bounds
      @pdf.bounding_box([0, @pdf.cursor], :width => 100) do
        @pdf.bounding_box([0, @pdf.cursor], :width => 100) do
          @pdf.reference_bounds.should == correct_bounds
        end
      end
    end
  end

  it "should return the margin box if there's no explicit bbox" do
    @pdf.reference_bounds.should == @pdf.margin_box

    @pdf.bounding_box([0, @pdf.cursor], :width => 100) do
      @pdf.reference_bounds.should == @pdf.margin_box
    end
  end

  it "should return the canvas box if we're in a canvas" do
    @pdf.canvas do
      canvas_box = @pdf.bounds

      @pdf.reference_bounds.should == canvas_box

      @pdf.bounding_box([0, @pdf.cursor], :width => 100) do
        @pdf.reference_bounds.should == canvas_box
      end
    end
  end

end

describe "BoundingBox#move_past_bottom" do
  before(:each) { create_pdf }

  it "should ordinarily start a new page" do
    @pdf.bounds.move_past_bottom
    @pdf.text "Foo"

    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == []
    pages[1][:strings].should == ["Foo"]
  end

  it "should move to the top of the next page if it exists already" do
    # save away the y-position at the top of a page
    top_y = @pdf.y

    # create a blank page but go to the page before it
    @pdf.start_new_page
    @pdf.go_to_page 1
    @pdf.text "Foo"

    @pdf.bounds.move_past_bottom
    @pdf.y.should.be.close(top_y, 0.001) # we should be at the top
    @pdf.text "Bar"

    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == ["Foo"]
    pages[1][:strings].should == ["Bar"]
  end
end
