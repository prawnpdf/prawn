# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

Prawn::Document.generate_example_document(__FILE__)
