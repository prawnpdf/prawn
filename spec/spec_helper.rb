require "rubygems"
require "spec"
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib') 
require "prawn"
require "pdf/reader"

def create_pdf
  @pdf = Prawn::Document.new
end    

def observer(klass)                                     
  output = @pdf.render
  obs = klass.new
  PDF::Reader.string(output,obs)
  obs   
end     

def parse_pdf_object(obj)
  PDF::Reader::Parser.new(
     PDF::Reader::Buffer.new(sio = StringIO.new(obj)), nil).parse_token   
end