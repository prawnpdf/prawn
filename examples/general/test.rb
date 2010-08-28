# encoding: utf-8
#
# This example demonstrates the use of the the outlines option for a new document
# it sets an initial outline item with a title
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

@pdf = Prawn::Document.new
@pdf.text "hello"
@pdf.render_file("one.pdf")
@pdf.text "hello again"
@pdf.render_file("two.pdf")

@pdf.render_file("three.pdf")
