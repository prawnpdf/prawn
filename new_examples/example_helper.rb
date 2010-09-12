$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'prawn'
require 'prawn/security'
require 'prawn/layout'


Prawn.debug = true

module Snippet
  def snippet(&block)
    bounding_box([bounds.left+10, cursor-10], :width => bounds.width-20) do
      font('Courier') do
        text snippet_source(block.to_s)
      end
    end
    
    yield
  end
  
  def snippet_source(block_data)
    file_name, line_number = Helper.parse_block_data(block_data)
    
    @examples ||= {file_name => File.readlines(file_name)}
    @examples[file_name] ||= File.readlines(file_name)
    
    snippet_end_line = @examples[file_name][line_number-1].sub(/snippet.*/, 'end')
    extra_spaces = @examples[file_name][line_number][/\s+/].length
    
    i = line_number
    output = ""
    while (line = @examples[file_name][i]) != snippet_end_line do
      output << Helper.use_non_breaking_spaces(Helper.remove_extra_spaces(line, extra_spaces))
      i += 1
    end
    output
  end
  
  module Helper
    extend self
    
    def parse_block_data(block_data)
      file_name, line_number = block_data.split('@').last.split(':')
      [file_name, line_number.to_i]
    end
    
    def remove_extra_spaces(string, quantity)
      string.sub(' '*quantity, '')
    end

    def use_non_breaking_spaces(string)
      string.gsub(' ', "\302\240")
    end
  end
end

Prawn::Document.extensions << Snippet
