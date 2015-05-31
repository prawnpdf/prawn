# encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A document's grid" do
  before do
    @pdf = Prawn::Document.new
  end

  it "should allow definition of a grid" do
    @pdf.define_grid(:columns => 5, :rows => 8, :gutter => 0.1)
    expect(@pdf.grid.columns).to eq(5)
    expect(@pdf.grid.rows).to eq(8)
    expect(@pdf.grid.gutter).to eq(0.1)
  end

  it "should allow re-definition of a grid" do
    @pdf.define_grid(:columns => 5, :rows => 8, :gutter => 0.1)
    expect(@pdf.grid.columns).to eq(5)
    expect(@pdf.grid.rows).to eq(8)
    expect(@pdf.grid.gutter).to eq(0.1)
    @pdf.define_grid(:columns => 3, :rows => 6, :gutter => 0.1)
    expect(@pdf.grid.columns).to eq(3)
    expect(@pdf.grid.rows).to eq(6)
    expect(@pdf.grid.gutter).to eq(0.1)
  end

  describe "when a grid is defined" do
    before do
      @num_columns = 5
      @num_rows = 8
      @gutter = 10.0
      @pdf.define_grid(
        :columns => @num_columns,
        :rows => @num_rows,
        :gutter => @gutter
      )
    end

    it "should compute the column width" do
      expect(@pdf.grid.column_width * @num_columns.to_f +
        @gutter * (@num_columns - 1).to_f).to eq(@pdf.bounds.width)
    end

    it "should compute the row height" do
      expect(@pdf.grid.row_height * @num_rows.to_f +
        @gutter * (@num_rows - 1).to_f).to eq(@pdf.bounds.height)
    end

    it "should give the edges of a grid box" do
      grid_width = (@pdf.bounds.width.to_f -
        (@gutter * (@num_columns - 1).to_f)) / @num_columns.to_f
      grid_height = (@pdf.bounds.height.to_f -
        (@gutter * (@num_rows - 1).to_f)) / @num_rows.to_f

      exp_tl_x = (grid_width + @gutter.to_f) * 4.0
      exp_tl_y = @pdf.bounds.height.to_f - (grid_height + @gutter.to_f)

      expect(@pdf.grid(1, 4).top_left).to eq([exp_tl_x, exp_tl_y])
      expect(@pdf.grid(1, 4).top_right).to eq([exp_tl_x + grid_width, exp_tl_y])
      expect(@pdf.grid(1, 4).bottom_left).to eq([exp_tl_x, exp_tl_y - grid_height])
      expect(@pdf.grid(1, 4).bottom_right).to eq([exp_tl_x + grid_width, exp_tl_y - grid_height])
    end

    it "should give the edges of a multiple grid boxes" do
      # Hand verified.  Cheating a bit.  Don't tell.
      expect(@pdf.grid([1, 3], [2, 5]).top_left).to eq([330.0, 628.75])
      expect(@pdf.grid([1, 3], [2, 5]).top_right).to eq([650.0, 628.75])
      expect(@pdf.grid([1, 3], [2, 5]).bottom_left).to eq([330.0, 456.25])
      expect(@pdf.grid([1, 3], [2, 5]).bottom_right).to eq([650.0, 456.25])
    end

    it "should draw outlines without changing global default colors to grid color" do
      @pdf.grid.show_all('cccccc')

      colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
      expect(colors.fill_color).not_to eq([0.8, 0.8, 0.8])
      expect(colors.stroke_color).not_to eq([0.8, 0.8, 0.8])

      # Hardcoded default color as I haven't been able to come up with a stable converter
      # between fill_color without lots code.
      expect(colors.stroke_color).to eq([0.0, 0.0, 0.0])
    end

    it "should draw outlines without curent color settings" do
      @pdf.fill_color "ccff00"
      @pdf.stroke_color "ffcc00"

      @pdf.grid.show_all

      colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
      expect(colors.fill_color).to eq([0.8, 1.0, 0.0])
      expect(colors.stroke_color).to eq([1.0, 0.8, 0.0])
    end
  end
end
