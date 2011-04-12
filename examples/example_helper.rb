$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require "bundler"
Bundler.setup

require 'prawn'
require 'prawn/security'
require "prawn/layout"


Prawn.debug = true
