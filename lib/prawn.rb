# frozen_string_literal: true

require 'set'

require 'ttfunk'
require 'pdf/core'

# Welcome to Prawn, the best PDF Generation library ever.
# This documentation covers user level functionality.
module Prawn
  file = __FILE__
  file = File.readlink(file) if File.symlink?(file)
  dir = File.dirname(file)

  # The base source directory for Prawn as installed on the system.
  BASEDIR = File.expand_path(File.join(dir, '..'))

  # Directory where Prawn keeps its data files.
  DATADIR = File.expand_path(File.join(dir, '..', 'data'))

  # @deprecated This is not used any more.
  FLOAT_PRECISION = 1.0e-9

  # When set to `true`, Prawn will verify hash options to ensure only valid keys
  # are used. Off by default.
  #
  # Example:
  #
  # ```shell
  # >> Prawn::Document.new(:tomato => "Juicy")
  # Prawn::Errors::UnknownOption:
  # Detected unknown option(s): [:tomato]
  # Accepted options are: [:page_size, :page_layout, :left_margin, ...]
  # ```
  #
  # @private
  # @return [Boolean]
  attr_accessor :debug

  module_function :debug, :debug=

  module_function

  # @private
  # @param accepted [Array<Symbol>] list of valid options
  # @param actual [Hash<Symbol, any>] opetions hash to validate
  # @return [void]
  # @raise [Prawn::Errors::UnknownOption]
  # @yield
  def verify_options(accepted, actual)
    return unless debug || $DEBUG

    unless (act = Set[*actual.keys]).subset?(acc = Set[*accepted])
      raise Prawn::Errors::UnknownOption,
        "\nDetected unknown option(s): #{(act - acc).to_a.inspect}\nAccepted options are: #{accepted.inspect}"
    end
    yield if block_given?
  end
end

require_relative 'prawn/version'

require_relative 'prawn/errors'

require_relative 'prawn/image_handler'
require_relative 'prawn/utilities'
require_relative 'prawn/text'
require_relative 'prawn/graphics'
require_relative 'prawn/images'
require_relative 'prawn/images/image'
require_relative 'prawn/images/jpg'
require_relative 'prawn/images/png'
require_relative 'prawn/stamp'
require_relative 'prawn/soft_mask'
require_relative 'prawn/security'
require_relative 'prawn/transformation_stack'
require_relative 'prawn/document'
require_relative 'prawn/font'
require_relative 'prawn/measurements'
require_relative 'prawn/repeater'
require_relative 'prawn/outline'
require_relative 'prawn/grid'
require_relative 'prawn/view'
