$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'prawn'
require 'prawn/security'
require "prawn/layout"


Prawn.debug = true

module Snippet
  def snippet(&block)
    @example_lines ||= {block.source_location.first => File.readlines(block.source_location.first)}
    str_end = @example_lines[block.source_location.first][block.source_location.last-1]
    str_end.sub!(/snippet.*/, 'end')
    i = block.source_location.last
    while((line = @example_lines[block.source_location.first][i]) != str_end) do
      text line
      i += 1
    end
    
    yield
  end
end

Prawn::Document.extensions << Snippet
