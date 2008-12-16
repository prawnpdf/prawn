# encoding: utf-8
#
# Shows that Prawn works out of the box with UTF-8 text, so long as you use
# a TTF file with the necessary glyphs for your content.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

Prawn::Document.generate("utf8.pdf") do
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  text "ὕαλον ϕαγεῖν δύναμαι· τοῦτο οὔ με βλάπτει." * 20
end

      