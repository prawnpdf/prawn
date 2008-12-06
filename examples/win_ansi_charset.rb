$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'

FONT_SIZE = 9.5

Prawn::Document.generate("win-ansi.pdf") do
  @skip_encoding = true

  x = 0
  y = bounds.top

  fields = [[20, :right], [8, :left], [12, :center], [30, :right], [8, :left], [0, :left]]

  font "Helvetica", :size => FONT_SIZE

  Prawn::Encoding::WinAnsi::CHARACTERS.each_with_index do |name, index|
    next if name == ".notdef"
    y -= FONT_SIZE

    if y < FONT_SIZE
      y = bounds.top - FONT_SIZE
      x += 170
    end

    code = "%d." % index
    char = index.chr

    width = 1000 * font.metrics.string_width(char, FONT_SIZE) / FONT_SIZE
    size = "%d" % width

    data = [code, nil, char, size, nil, name]
    dx = x
    fields.zip(data).each do |(total_width, align), field|
      if field
        width = font.metrics.string_width(field, FONT_SIZE)

        case align
        when :left then offset = 0
        when :right then offset = total_width - width
        when :center then offset = (total_width - width)/2
        end

        text(field, :at => [dx + offset, y])
      end

      dx += total_width
    end
  end
end
