require "rubygems"
require "spec"
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib') 
require "prawn"
require "pdf/reader"

def parse_pdf_object(obj)
  PDF::Reader::Parser.new(
     PDF::Reader::Buffer.new(sio = StringIO.new(obj)), nil).parse_token   
end