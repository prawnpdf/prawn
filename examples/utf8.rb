# coding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("utf8.pdf") do
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  text "ὕαλον ϕαγεῖν δύναμαι· τοῦτο οὔ με βλάπτει." * 20
end
