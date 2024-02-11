# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Measurement Extensions'

  text do
    prose <<~TEXT
      The base unit in Prawn is the PDF Point. One PDF Point is equal to 1/72
      of an inch.

      There is no need to waste time converting this measure. Prawn provides
      helpers for converting from other measurements to PDF Points.

      Just <code>require "prawn/measurement_extensions"</code> and it will mix
      some helpers onto <code>Numeric</code> for converting common measurement
      units to PDF Points.
    TEXT
  end

  example do
    require 'prawn/measurement_extensions'

    %i[mm cm dm m in yd ft].each do |measurement|
      text "1 #{measurement} in PDF Points: #{1.public_send(measurement)} pt"
      move_down 5.mm
    end
  end
end
