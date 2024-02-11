# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Text Rendering Modes'

  text do
    prose <<~TEXT
      You have already seen how to set the text color using both inline
      formatting and the format text methods. There is another way by using the
      graphics methods <code>fill_color</code> and <code>stroke_color</code>.

      When reading the graphics reference you learned about fill and stroke. If
      you haven't read it before, read it now before continuing.

      Text can be rendered by being filled (the default mode) or just stroked,
      or both filled and stroked. This can be set using the
      <code>text_rendering_mode</code> method or the <code>:mode</code> option
      on the text methods.
    TEXT
  end

  example do
    fill_color '00ff00'
    stroke_color '0000ff'

    font_size(40) do
      # normal rendering mode: fill
      text 'This text is filled with green.'

      # inline rendering mode: stroke
      text 'This text is stroked with blue', mode: :stroke

      # block rendering mode: fill and stroke
      text_rendering_mode(:fill_stroke) do
        text 'This text is filled with green and stroked with blue'
      end
    end
  end
end
