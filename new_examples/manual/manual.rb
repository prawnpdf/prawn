# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("manual.pdf") do
  title = "Prawn by Example"
  text title, :size => 40
  
  outline.define do
    section title, :destination => page_number
  end
  
  
  start_new_page
  
  text "Foreword, by Greg Brown", :size => 20
  
  outline.add_subsection_to title do
    outline.section "Foreword", :destination => page_number
  end
  
  
  start_new_page
  
  text "How to read this manual", :size => 20
  
  outline.add_subsection_to title do
    outline.section "How to read this manual", :destination => page_number
  end
  
  text "All code snippets from this manual are meant to be used inside a Prawn::Document.generate implicit block. If that is not the case the full code is provided."
  
  start_new_page
  load_package "document"
  
  start_new_page
  load_package "graphics"
  
  start_new_page
  load_package "text"
end
