module Prawn
  class Canvas
    include Prawn::Chunkable

    def initialize
      @chunks = []
    end

    attr_accessor :chunks

    chunk_methods :move_to, :line_to, :line, :stroke, :fill,
                  :curve_to, :curve, :rectangle, :ellipse, :circle

    def move_to!(params)
      chunk(:move_to, params) do |c|
        "%.3f %.3f m" % c[:point]
      end
    end

    def line_to!(params)
      chunk(:line_to, params) do |c|
        "%.3f %.3f l" % c[:point]
      end
    end

    def curve_to!(params)
      unless params[:bound1] && params[:bound2]
        raise Prawn::Errors::InvalidGraphicsPath
      end

      chunk(:curve_to, params) do |c|
        "%.3f %.3f %.3f %.3f %.3f %.3f c" % (c[:bound1] + c[:bound2] + c[:point])
      end
    end

    def curve!(params)
      chunk(:curve, params) do |c|
        [ move_to!(:point => params[:point1]),
          curve_to!(:point  => params[:point2],
                    :bound1 => params[:bound1],
                    :bound2 => params[:bound2]) ]

      end
    end
    
    KAPPA = 4.0 * ((Math.sqrt(2) - 1.0) / 3.0)

    def ellipse!(params)
      chunk(:ellipse, params) do |c|
        x, y = c[:point]
        r1   = c[:x_radius]
        r2   = c[:y_radius]

        l1 = r1 * KAPPA
        l2 = r2 * KAPPA

        start          =  move_to!(:point => [x + r1, y])

        to_upper_right = curve_to!(:point  => [x,  y + r2],
                                   :bound1 => [x + r1, y + l1], 
                                   :bound2 => [x + l2, y + r2])
        to_upper_left = curve_to!(:point => [x - r1, y],
                                  :bound1 => [x - l2, y + r2],
                                  :bound2 => [x - r1, y + l1])
        
        to_lower_left = curve_to!(:point => [x, y - r2],
                                  :bound1 => [x - r1, y - l1], 
                                  :bound2 => [x - l2, y - r2])

        to_lower_right = curve_to!(:point  => [x + r1, y],
                                   :bound1 => [x + l2, y - r2], 
                                   :bound2 => [x + r1, y - l1])

        back_to_start = move_to!(:point => [x,y])

        [start, to_upper_right, to_upper_left,
                to_lower_left,  to_lower_right, back_to_start]
      end
    end

    def circle!(params)
      chunk(:circle, params) do
        ellipse!(:point    => params[:point],
                 :x_radius => params[:radius],
                 :y_radius => params[:radius]) 
                    
      end
    end

    def line!(params)
      chunk(:line, params) do |c|
        [ move_to!(:point => c.params[:point1]), 
          line_to!(:point => c.params[:point2]) ]
      end
    end

    def stroke!
      chunk(:stroke) { "S" }
    end

    def fill!
      chunk(:fill) { "F" }
    end

    def fill_and_stroke!
      chunk(:fill_and_stroke) { "b" }
    end
     
    def rectangle!(params)
      chunk(:rectangle, params) do |c|
        x,y = params[:point]
        y  -= params[:height]

        "%.3f %.3f %.3f %.3f re" % [ x, y, params[:width], params[:height] ]
      end
    end

  end
end
