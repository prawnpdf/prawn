$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'bundler'
require 'prawn'
Bundler.require

##
# When this is fixed then Testing should appear with normal default black color in Acrobat reader

Prawn::Document.generate("looks_blank.pdf") do

  repeat :all do
    text "Testing", :size => 24, :style => :bold
  end

  fill_color '662255'

end
