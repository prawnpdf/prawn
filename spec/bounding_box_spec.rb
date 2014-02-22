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
    end.should raise_error(ArgumentError)
  end

  it "should raise_error an ArgumentError if a block is not passed" do
    pdf = Prawn::Document.new
    lambda do
      pdf.bounding_box([0, 0], :width => 200)
    end.should raise_error(ArgumentError)
  end

end

describe "drawing bounding boxes" do

  before(:each) { create_pdf }

  it "should not stomp on the arguments to bounding_box" do
    pdf = Prawn::Document.new
    x = [100, 500]
    pdf.bounding_box x, :width => 100 do
      pdf.text "bork-bork-bork"
    end
    x.should == [100, 500]
  end

  it "should restore Document#bounds to the correct margin box on exit" do
    pdf = Prawn::Document.new(:margin => 200)

    # add a multi-page bounding box
    pdf.bounding_box([100, pdf.bounds.top], :width => 400) do
      pdf.text "The rain in spain falls mainly in the plains.\n" * 30
    end

    pdf.start_new_page(:margin => 0)

    x_min, y_min, x_max, y_max = pdf.page.dimensions

    pdf.bounds.absolute_top_left.should == [x_min, y_max]
    pdf.bounds.absolute_bottom_right.should == [x_max, y_min]
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

    @pdf.y.should be_within(0.001).of(458.384)
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
    @pdf.y.should be_within(0.001).of(orig_y - 30)
  end

  it "should not advance y-position if passed :hold_position => true" do
    orig_y = @pdf.y
    @pdf.bounding_box [0, @pdf.cursor], :width => @pdf.bounds.width,
        :hold_position => true do
      @pdf.text "hello"
    end
    # y only advances by height of one line ("hello")
    @pdf.y.should be_within(0.001).of(orig_y - @pdf.height_of("hello"))
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
    @pdf.y.should be_within(0.001).of(
      @pdf.margin_box.absolute_top - @pdf.height_of("hello")
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
          @pdf.bounds.width.should be_within(0.01).of(width - 20)
        end
      end
    end

    it "should subtract right padding from the available width" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width,
                      :height => 200, :columns => 2, :spacer => 20) do
        width = @pdf.bounds.width
        @pdf.indent(20, 30) do
          @pdf.bounds.width.should be_within(0.01).of(width - 50)
        end
      end
    end

    it "should maintain the same left indentation across column breaks" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width, :columns => 3, :spacer => 15) do
        3.times do |column|
          x = @pdf.bounds.left_side
          @pdf.indent(20) do
            @pdf.bounds.left_side.should == x+20
          end
          @pdf.bounds.move_past_bottom
        end
      end
    end

    it "should not change the right margin if only left indentation is requested" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width, :columns => 3, :spacer => 15) do
        3.times do |column|
          x = @pdf.bounds.right_side
          @pdf.indent(20) do
            @pdf.bounds.right_side.should == x
          end
          @pdf.bounds.move_past_bottom
        end
      end
    end

    it "should maintain the same right indentation across columns" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width, :columns => 3, :spacer => 15) do
        3.times do |column|
          x = @pdf.bounds.right_side
          @pdf.indent(20, 10) do
            @pdf.bounds.right_side.should == x-10
          end
          @pdf.bounds.move_past_bottom
        end
      end
    end

    it "should keep the right indentation after nesting indents" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width, :columns => 3, :spacer => 15) do
        3.times do |column|
          # I am giving a right indent of 10...
          @pdf.indent(20, 10) do
            x = @pdf.bounds.right_side
            # ...and no right indent here...
            @pdf.indent(20) do
              # right indent is inherited from the parent!
              @pdf.bounds.right_side.should == x
            end
          end
          @pdf.bounds.move_past_bottom
        end
      end
    end

    it "should revert the right indentation if negative indent is given in nested indent" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width, :columns => 3, :spacer => 15) do
        3.times do |column|
          x = @pdf.bounds.right_side
          @pdf.indent(20, 10) do
            # requesting a negative right-indent of equivalent size...
            @pdf.indent(20, -10) do
              # ...resets the right margin to that of the column!
              @pdf.bounds.right_side.should == x
            end
          end
          @pdf.bounds.move_past_bottom
        end
      end
    end

    it "should reduce the available column width by the sum of all nested indents" do
      @pdf.column_box([0, @pdf.cursor], :width => @pdf.bounds.width, :columns => 3, :spacer => 15) do
        3.times do |column|
          w = @pdf.bounds.width
          @pdf.indent(20, 10) do
            @pdf.indent(20, 10) do
              @pdf.bounds.width.should == w - 60
            end
          end
          @pdf.bounds.move_past_bottom
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

  it "should restore the original ypos after execution", :issue => 523 do
    doc = Prawn::Document.new(:skip_page_creation => true)
    doc.start_new_page

    original_ypos = doc.y

    doc.canvas {}

    doc.y.should == original_ypos
  end

end

describe "Deep-copying" do
  it "should create a new object that does not copy @document" do
    Prawn::Document.new do |pdf|
      orig = pdf.bounds
      copy = orig.deep_copy

      copy.should_not == pdf.bounds
      copy.document.should be_nil
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
        copy.parent.should_not == outside
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
    @pdf.y.should be_within(0.001).of(top_y)
    @pdf.text "Bar"

    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == ["Foo"]
    pages[1][:strings].should == ["Bar"]
  end
end
