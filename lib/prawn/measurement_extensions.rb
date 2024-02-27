# frozen_string_literal: true

require_relative 'measurements'

# @group Stable API

# Core extensions for {Prawn::Measurements}.
#
# This mainly enables measurements DSL.
#
# You have to explicitly require "prawn/measurement_extensions" to enable these.
#
# ```ruby
# require 'prawn/measurement_extensions'
#
# 12.mm
# 2.cm
# 0.5.in
# 4.yd + 2.ft
# ```
class Numeric
  include Prawn::Measurements
  # Prawn's basic unit is PostScript-Point: 72 points per inch.

  # @group Experimental API

  # Convert from millimeters to points.
  #
  # @return [Number]
  def mm
    mm2pt(self)
  end

  # Convert from centimeters to points.
  #
  # @return [Number]
  def cm
    cm2pt(self)
  end

  # Convert from decimeters to points.
  #
  # @return [Number]
  def dm
    dm2pt(self)
  end

  # Convert from meters to points.
  #
  # @return [Number]
  def m
    m2pt(self)
  end

  # Convert from inches to points.
  #
  # @return [Number]
  def in
    in2pt(self)
  end

  # Convert from yards to points.
  #
  # @return [Number]
  def yd
    yd2pt(self)
  end

  # Convert from feet to points.
  #
  # @return [Number]
  def ft
    ft2pt(self)
  end

  # Convert from points to points.
  #
  # @return [Number]
  def pt
    pt2pt(self)
  end
end
