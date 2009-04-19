# encoding: utf-8
#
# As of 7d8d466e6415c16d594fb4c4fd3207a0f52e545c ...
#
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate('vera-test.pdf') do
  font_families["Vera"] = {
    :normal => "#{Prawn::BASEDIR}/data/fonts/Vera.ttf"
  }
  font "Vera"
  text "Using Vera Verbosely", :size => 20
end
