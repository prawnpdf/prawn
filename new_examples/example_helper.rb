# encoding: utf-8
#
# Helper for organizing examples
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'prawn'
require 'prawn/security'
require 'prawn/layout'


Prawn.debug = true

class Example < Prawn::Document
  
  def self.generate_example_document(filename, examples)
    generate(filename) do
      text "#{filename.capitalize.gsub('.pdf', '')} Reference", :size => 30
      
      examples.each do |example|
        start_new_page
        
        text example, :size => 20
        move_down 10
        
        load_example(example)
      end
    end
  end
  
  def load_example(filename)
    data = File.read(filename)
    example_source = extract_source(data)
    
    text extract_introduction_text(data)
    
    bounding_box([bounds.left, cursor-10], :width => bounds.width) do
      font('Courier', :size => 11) do
        text example_source.gsub(' ', Prawn::Text::NBSP)
      end
    end
    
    eval example_source
  end
  
  def drawing_box(options={})
    options = { :width => bounds.width-20 }.merge(options)
    top_left = [bounds.left+10, cursor-10]
  
    bounding_box(top_left, options) do
      yield
      stroke_bounds
    end
  end

private

  # Returns anything within the Example.generate block
  def extract_source(source)
    source.slice(/\w+\.generate.*? do(.*)end/m, 1) or source
  end
  
  # Returns the comments between the encoding declaration and the require
  def extract_introduction_text(source)
    source.slice(/# encoding.*?\n(.*)require/m, 1).gsub(/#\s?/, '')
  end
  
end
