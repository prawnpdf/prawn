# encoding: utf-8
#
# Prawn enables the declaration of fallback fonts for those glyphs that may not
# be present in the desired font. Use the :fallback_fonts option with any of the
# text or text box methods, or set fallback_fonts document-wide.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  file = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
  font_families["Kai"] = {
    :normal => { :file => file, :font => "Kai" }
  }
  file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
  font_families["Action Man"] = {
    :normal      => { :file => file, :font => "ActionMan" },
  }
  font("Action Man") do
    text("When fallback fonts are included, each glyph will be rendered using " +
         "the first font that includes the glyph, starting with the current " +
         "font and then moving through the fallback fonts from left to right." +
         "\n\n" +
         "hello ƒ 你好\n再见 ƒ goodbye",
         :fallback_fonts => ["Times-Roman", "Kai"])
  end
  move_down 20

  formatted_text([
                  { :text => "Fallback fonts can even override" },
                  { :text => "fragment fonts (你好)", :font => "Times-Roman" },
                 ],
                 :fallback_fonts => ["Times-Roman", "Kai"])
end
