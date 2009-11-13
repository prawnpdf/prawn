# encoding: utf-8
#
# As of 200fc36455fa3bee0e1e3bb25d1b5bf73dbf3b52,
# the following code does not correctly render a PNG image
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..','lib')
require "prawn/core"

Prawn::Document.generate('png_barcode_issue.pdf') do
  image "#{Prawn::BASEDIR}/data/images/barcode_issue.png"
end
