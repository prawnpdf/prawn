# frozen_string_literal: true

# Prints a list of all of the glyphs that can be rendered by Adobe's built
# in fonts, along with their character widths and WinAnsi codes.  Be sure
# to pass these glyphs as UTF-8, and Prawn will transcode them for you.

require_relative '../example_helper'

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  font_size = 9.5

  x = 0
  y = bounds.top

  fields = [
    [20, :right], [8, :left], [12, :center], [30, :right], [8, :left],
    [0, :left]
  ]

  font 'Helvetica', size: font_size

  start_new_page

  Prawn::Encoding::WinAnsi::CHARACTERS.each_with_index do |name, index|
    next if name == '.notdef'

    y -= font_size

    if y < font_size
      y = bounds.top - font_size
      x += 170
    end

    code = format('%<index>d.', index: index)
    char = index.chr.force_encoding(::Encoding::Windows_1252)

    width = 1000 * width_of(char, size: font_size) / font_size
    size = format('%<width>d', width: width)

    data = [code, nil, char, size, nil, name]
    dx = x
    fields.zip(data).each do |(total_width, align), field|
      if field
        width = width_of(field, size: font_size)

        case align
        when :left then offset = 0
        when :right then offset = total_width - width
        when :center then offset = (total_width - width) / 2
        end

        text_box(
          field.dup.force_encoding('windows-1252').encode('UTF-8'),
          at: [dx + offset, y]
        )
      end

      dx += total_width
    end
  end
end
