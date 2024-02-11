# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Font Size'

  text do
    prose <<~TEXT
      The <code>font_size</code> method works just like the <code>font</code>
      method.

      In fact we can even use <code>font</code> with the <code>:size</code>
      option to declare which size we want.

      Another way to change the font size is by supplying the
      <code>:size</code> option to the text methods.

      The default font size is <code>12</code>.
    TEXT
  end

  example do
    text "Let's see which is the current font_size: #{font_size.inspect}"

    font_size 16
    text 'Yeah, something bigger!'

    font_size(25) { text 'Even bigger!' }

    text 'Back to 16 again.'

    text 'Single line on 20 using the :size option.', size: 20

    text 'Back to 16 once more.'

    font('Courier', size: 10) do
      text 'Yeah, using Courier 10 courtesy of the font method.'
    end

    font('Helvetica', size: 12)
    text 'Back to normal'
  end
end
