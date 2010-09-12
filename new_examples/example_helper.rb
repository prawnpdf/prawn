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
  
  def self.generate_example_document(filename)
    examples_folder = File.dirname(filename)
    
    document_name = examples_folder[/[^\/]+$/]
    document_file_name = "#{document_name}.pdf"
    
    generate(document_file_name) do
      text "#{document_name.capitalize} Reference", :size => 30
      
      Dir.chdir(examples_folder) do
        examples = Dir['*.rb'].reject{|file| file == filename[/[^\/]+$/]}
        examples.each do |example|
          start_new_page
          load_example(example)
        end
      end
      
    end
  end
  
  def load_example(filename)
    example_source = File.read(filename)
    
    bounding_box([bounds.left+10, cursor-10], :width => bounds.width-20) do
      font('Courier', :size => 11) do
        text example_source.gsub(' ', "\302\240")
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
  
  
end
