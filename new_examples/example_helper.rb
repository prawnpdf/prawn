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

module Examples
  
  def load_example(filename)
    example_source = File.read(filename)
    
    bounding_box([bounds.left+10, cursor-10], :width => bounds.width-20) do
      font('Courier') do
        text example_source.gsub(' ', "\302\240")
      end
    end
    
    eval example_source
  end
  
  module Singleton
    
    def generate_example_document(filename)
      example_folder = File.dirname(filename)
      
      document_name = example_folder[/[^\/]+$/] << '.pdf'
      
      Prawn::Document.generate(document_name) do
        
        Dir.chdir(example_folder) do
          Dir['*.rb'].reject{|file| file == filename[/[^\/]+$/]}.each do |example|
            load_example(example)
          end
        end
        
      end
    end
  end
end

Prawn::Document.extensions << Examples
Prawn::Document.extend Examples::Singleton
