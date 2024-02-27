# frozen_string_literal: true

# rubocop: disable Naming/MethodParameterName
module Prawn
  # @group Stable API

  # Distance unit conversions between metric, imperial, and PDF.
  module Measurements
    # metric conversions

    # Convert centimeter to millimeters.
    #
    # @param cm [Number]
    # @return [Number]
    def cm2mm(cm)
      cm * 10
    end

    # Convert decimeters to millimeters.
    #
    # @param dm [Number]
    # @return [Number]
    def dm2mm(dm)
      dm * 100
    end

    # Convert meters to millimeters.
    #
    # @param m [Number]
    # @return [Number]
    def m2mm(m)
      m * 1000
    end

    # imperial conversions
    # from http://en.wikipedia.org/wiki/Imperial_units

    # Convert feet to inches.
    #
    # @param ft [Number]
    # @return [Number]
    def ft2in(ft)
      ft * 12
    end

    # Convert yards to inches.
    #
    # @param yd [Number]
    # @return [Number]
    def yd2in(yd)
      yd * 36
    end

    # PostscriptPoint-converisons

    # Convert points to points. For completeness.
    #
    # @param pt [Number]
    # @return [Number]
    def pt2pt(pt)
      pt
    end

    # Convert inches to points.
    #
    # @param inch [Number]
    # @return [Number]
    def in2pt(inch)
      inch * 72
    end

    # Convert feet to points.
    #
    # @param ft [Number]
    # @return [Number]
    def ft2pt(ft)
      in2pt(ft2in(ft))
    end

    # Convert yards to points.
    #
    # @param yd [Number]
    # @return [Number]
    def yd2pt(yd)
      in2pt(yd2in(yd))
    end

    # Convert millimeters to points.
    #
    # @param mm [Number]
    # @return [Number]
    def mm2pt(mm)
      mm * (72 / 25.4)
    end

    # Convert centimeters to points.
    #
    # @param cm [Number]
    # @return [Number]
    def cm2pt(cm)
      mm2pt(cm2mm(cm))
    end

    # Convert decimeters to points.
    #
    # @param dm [Number]
    # @return [Number]
    def dm2pt(dm)
      mm2pt(dm2mm(dm))
    end

    # Convert meters to points.
    #
    # @param m [Number]
    # @return [Number]
    def m2pt(m)
      mm2pt(m2mm(m))
    end

    # Convert points to millimeters.
    #
    # @param pt [Number]
    # @return [Number]
    def pt2mm(pt)
      pt * 1 / mm2pt(1) # (25.4 / 72)
    end
  end
end
# rubocop: enable Naming/MethodParameterName
