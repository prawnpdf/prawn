# encoding: UTF-8

require_relative "../lib/prawn"
require "prawn/manual_builder"

Prawn::ManualBuilder.manual_dir = File.dirname(__FILE__)
