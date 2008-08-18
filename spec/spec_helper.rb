# encoding: utf-8

puts "Prawn specs: Running on Ruby Version: #{RUBY_VERSION}"

require "rubygems"
require "test/spec"                                                
require "mocha"
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib') 
require "prawn"
gem 'pdf-reader', ">=0.7.3"
require "pdf/reader"

module Prawn
  class Document
    public :ref
  end
end

def create_pdf
  @pdf = Prawn::Document.new(:left_margin   => 0,
                             :right_margin  => 0,
                             :top_margin    => 0,
                             :bottom_margin => 0)
end    

def observer(klass)                                     
  @output = @pdf.render
  obs = klass.new
  PDF::Reader.string(@output,obs)
  obs   
end     

def parse_pdf_object(obj)
  PDF::Reader::Parser.new(
     PDF::Reader::Buffer.new(sio = StringIO.new(obj)), nil).parse_token   
end    