# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Fill and Stroke'

  text do
    prose <<~TEXT
      There are two drawing primitives in Prawn: <code>fill</code> and
      <code>stroke</code>.

      These are the methods that actually draw stuff on the document. All the
      other drawing shapes like <code>rectangle</code>, <code>circle</code> or
      <code>line_to</code> define drawing paths. These paths need to be either
      stroked or filled to gain form on the document.

      Calling these methods without a block will act on the drawing path that
      has been defined prior to the call.

      Calling with a block will act on the drawing path set within the block.

      Most of the methods which define drawing paths have methods of the same
      name starting with stroke_ and fill_ which create the drawing path and
      then stroke or fill it.
    TEXT
  end

  example axes: true do
    # No block
    line [0, 200], [100, 150]
    stroke

    rectangle [0, 100], 100, 100
    fill

    # With block
    stroke { line [200, 200], [300, 150] }
    fill { rectangle [200, 100], 100, 100 }

    # Method hook
    stroke_line [400, 200], [500, 150]
    fill_rectangle [400, 100], 100, 100
  end
end
