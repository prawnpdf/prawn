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
  
end

Prawn::Document.extensions << Examples
