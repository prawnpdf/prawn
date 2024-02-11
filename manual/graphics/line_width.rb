# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Line Width'

  text do
    prose <<~TEXT
      The <code>line_width=</code> method sets the stroke width for subsequent
      stroke calls.

      Since Ruby assumes that an unknown variable on the left hand side of an
      assignment is a local temporary, rather than a setter method, if you are
      using the block call to <code>Prawn::Document.generate</code> without
      passing params you will need to call <code>line_width</code> on self.
    TEXT
  end

  example axes: true do
    y = 225

    3.times do |i|
      case i
      when 0 then line_width = 10 # This call will have no effect
      when 1 then self.line_width = 10
      when 2 then self.line_width = 25
      end

      stroke do
        horizontal_line 25, 75, at: y
        rectangle [225, y + 25], 50, 50
        circle [450, y], 25
      end

      y -= 90
    end
  end
end
