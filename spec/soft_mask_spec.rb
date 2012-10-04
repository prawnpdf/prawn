require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

module SoftMaskHelper
  def make_soft_mask
    @pdf.save_graphics_state do
      @pdf.soft_mask do
        if block_given?
          yield
        else
          @pdf.fill_color '808080'
          @pdf.fill_rectangle [100, 100], 200, 200
        end
      end

      @pdf.fill_color '000000'
      @pdf.fill_rectangle [0, 0], 200, 200
    end
  end
end

module PDF
  class Inspector
    class ExtGState
      def resource_extgstate(*params)
        @extgstates << {
                        :opacity => params[1][:ca],
                        :stroke_opacity => params[1][:CA],
                        :soft_mask => params[1][:SMask]
                        }
      end
    end
  end
end

describe "Document with soft masks" do

  include SoftMaskHelper

  it "the PDF version should be at least 1.4" do
    create_pdf
    make_soft_mask
    str = @pdf.render
    str[0,8].should == "%PDF-1.4"
  end

  it "a new extended graphics state should be created for "+
     "each unique soft mask" do
    create_pdf

    make_soft_mask do
      @pdf.fill_color '808080'
      @pdf.fill_rectangle [100, 100], 200, 200
    end

    make_soft_mask do
      @pdf.fill_color '808080'
      @pdf.fill_rectangle [10, 10], 200, 200
    end

    extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
    extgstates.length.should == 2
  end

  it "a new extended graphics state should contain soft mask with drawing instructions" do
    create_pdf

    make_soft_mask do
      @pdf.fill_color '808080'
      @pdf.fill_rectangle [100, 100], 200, 200
    end

    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates.first
    extgstate[:soft_mask][:G].data.should == "q\n/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\n1 w\n0 J\n0 j\n[ ] 0 d\n/DeviceRGB cs\n0.502 0.502 0.502 scn\n100.000 -100.000 200.000 200.000 re\nf\nQ\n\n"
  end
end
