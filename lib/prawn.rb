# encoding: utf-8
 
# prawn.rb : A library for PDF generation in Ruby
#
# Copyright April 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
           
%w[ttfunk/lib].each do |dep|
  $LOAD_PATH.unshift(File.dirname(__FILE__) + "/../vendor/#{dep}")
end
 
require 'ttfunk'
 
module Prawn
  file = __FILE__
  file = File.readlink(file) if File.symlink?(file)
  dir = File.dirname(file)
                          
  # The base source directory for Prawn as installed on the system
  BASEDIR = File.expand_path(File.join(dir, '..'))
  
  VERSION = "0.4.1"
  
  extend self

  # Whe set to true, Prawn will verify hash options to ensure only valid keys
  # are used.  Off by default.
  # 
  attr_accessor :debug
  
  def verify_options(accepted,actual) #:nodoc:
    return unless debug || $DEBUG
    require "set"
    unless (act=Set[*actual.keys]).subset?(acc=Set[*accepted])
      raise Prawn::Errors::UnknownOption,
        "\nDetected unknown option(s): #{(act - acc).to_a.inspect}\n" <<
        "Accepted options are: #{accepted.inspect}"
    end
    yield if block_given?
  end
  
  module Configurable #:nodoc:
    def configuration(*args)
      @config ||= Marshal.load(Marshal.dump(default_configuration))
      if Hash === args[0]
        @config.update(args[0])
      elsif args.length > 1
        @config.values_at(*args)
      elsif args.length == 1
        @config[args[0]]
      else
        @config
      end
    end
    
    alias_method :C, :configuration
  end
end
 
require "prawn/compatibility"
require "prawn/errors"
require "prawn/pdf_object"
require "prawn/graphics"
require "prawn/images"
require "prawn/images/jpg"
require "prawn/images/png"
require "prawn/document"
require "prawn/reference"
require "prawn/font"
require "prawn/encoding"
require "prawn/measurements"
