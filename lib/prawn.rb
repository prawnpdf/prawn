# Welcome to Prawn, the best PDF Generation library ever.
# This documentation covers user level functionality.
#
require 'set'

require 'ttfunk'
require 'pdf/core'

module Prawn
  file = __FILE__
  file = File.readlink(file) if File.symlink?(file)
  dir = File.dirname(file)

  # The base source directory for Prawn as installed on the system
  #
  #
  BASEDIR = File.expand_path(File.join(dir, '..'))
  DATADIR = File.expand_path(File.join(dir, '..', 'data'))

  FLOAT_PRECISION = 1.0e-9

  # When set to true, Prawn will verify hash options to ensure only valid keys
  # are used.  Off by default.
  #
  # Example:
  #   >> Prawn::Document.new(:tomato => "Juicy")
  #   Prawn::Errors::UnknownOption:
  #   Detected unknown option(s): [:tomato]
  #   Accepted options are: [:page_size, :page_layout, :left_margin, ...]
  #
  attr_accessor :debug # @private
  module_function :debug, :debug=

  def verify_options(accepted, actual) # @private
    return unless debug || $DEBUG
    unless (act = Set[*actual.keys]).subset?(acc = Set[*accepted])
      raise Prawn::Errors::UnknownOption,
        "\nDetected unknown option(s): #{(act - acc).to_a.inspect}\n" \
        "Accepted options are: #{accepted.inspect}"
    end
    yield if block_given?
  end
  module_function :verify_options
end

require 'prawn/version'

require 'prawn/errors'

require 'prawn/utilities'
require 'prawn/text/formatted/fragment'
require 'prawn/text/formatted/parser'
require 'prawn/text/formatted/wrap'
require 'prawn/text/formatted/box'
require 'prawn/text/formatted/line_wrap'
require 'prawn/text/formatted/arranger'
require 'prawn/text'
require 'prawn/text/box'

require 'prawn/graphics/blend_mode'
require 'prawn/graphics/color'
require 'prawn/graphics/dash'
require 'prawn/graphics/cap_style'
require 'prawn/graphics/join_style'
require 'prawn/graphics/transparency'
require 'prawn/graphics/transformation'
require 'prawn/graphics/patterns'
require 'prawn/graphics'

require 'prawn/images'
require 'prawn/images/image'
require 'prawn/images/jpg'
require 'prawn/images/png'
require 'prawn/stamp'
require 'prawn/soft_mask'
require 'prawn/security'
require 'prawn/security/arcfour'

require 'prawn/transformation_stack'

require 'prawn/document/bounding_box'
require 'prawn/document/column_box'
require 'prawn/document/internals'
require 'prawn/document/span'
require 'prawn/document/bounding_box'
require 'prawn/document'

require 'prawn/encoding'

require 'prawn/font/afm'
require 'prawn/font/ttf'
require 'prawn/font/dfont'
require 'prawn/font/ttc'
require 'prawn/font_metric_cache'
require 'prawn/font'

require 'prawn/measurements'
require 'prawn/repeater'
require 'prawn/outline'
require 'prawn/grid'
require 'prawn/view'
require 'prawn/image_handler'

Prawn.image_handler.register(Prawn::Images::PNG)
Prawn.image_handler.register(Prawn::Images::JPG)
