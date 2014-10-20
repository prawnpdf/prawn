# encoding: utf-8

# Welcome to Prawn, the best PDF Generation library ever.
# This documentation covers user level functionality.
#
require "set"

require 'ttfunk'
require "pdf/core"

module Prawn
  extend self

  file = __FILE__
  file = File.readlink(file) if File.symlink?(file)
  dir  = File.dirname(file)

  # The base source directory for Prawn as installed on the system
  #
  #
  BASEDIR = File.expand_path(File.join(dir, '..'))
  DATADIR = File.expand_path(File.join(dir, '..', 'data'))

  FLOAT_PRECISION = 1.0e-9

  # Whe set to true, Prawn will verify hash options to ensure only valid keys
  # are used.  Off by default.
  #
  # Example:
  #   >> Prawn::Document.new(:tomato => "Juicy")
  #   Prawn::Errors::UnknownOption:
  #   Detected unknown option(s): [:tomato]
  #   Accepted options are: [:page_size, :page_layout, :left_margin, ...]
  #
  attr_accessor :debug # @private

  def verify_options(accepted, actual) # @private
    return unless debug || $DEBUG
    unless (act=Set[*actual.keys]).subset?(acc=Set[*accepted])
      raise Prawn::Errors::UnknownOption,
        "\nDetected unknown option(s): #{(act - acc).to_a.inspect}\n" <<
        "Accepted options are: #{accepted.inspect}"
    end
    yield if block_given?
  end

  module Configurable # @private
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

require_relative "prawn/version"

require_relative "prawn/errors"

require_relative "prawn/utilities"
require_relative "prawn/text"
require_relative "prawn/graphics"
require_relative "prawn/images"
require_relative "prawn/images/image"
require_relative "prawn/images/jpg"
require_relative "prawn/images/png"
require_relative "prawn/stamp"
require_relative "prawn/soft_mask"
require_relative "prawn/security"
require_relative "prawn/document"
require_relative "prawn/font"
require_relative "prawn/measurements"
require_relative "prawn/repeater"
require_relative "prawn/outline"
require_relative "prawn/grid"
require_relative "prawn/view"
require_relative "prawn/image_handler"

Prawn.image_handler.register(Prawn::Images::PNG)
Prawn.image_handler.register(Prawn::Images::JPG)
