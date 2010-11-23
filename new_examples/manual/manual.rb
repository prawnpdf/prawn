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
  move_down 20
  
  outline.add_subsection_to title do
    outline.section "How to read this manual", :destination => page_number
  end
  
  text <<-END_TEXT
  This manual is a collection of examples categorized by theme and organized from the least complex to the most complex. While it is a thorough walkthrough it does not aim to be a comprehensive guide.
  
  The best way to read it depends on your previous knowledge of Prawn and what your needs are.
  
  If you are beginning with Prawn the first chapter will teach you the most basic concepts and how to create pdf documents. For an overview of the other features each chapter beyond the first has a Basics section which offer enough insight on the feature without showing all the advanced stuff you might never use.
  
  Once you understand the basics you might want to come back to this manual looking for examples that accomplish tasks you need.
  
  Advanced users are encouraged to go beyond this manual and read the source code directly and clear any doubts that might not be in the scope of this manual.
  
  Most of the code snippets shown on this manual are actually ran
  END_TEXT
  
  move_down 40
  text "Reading the examples", :size => 20
  move_down 20
  text <<-END_TEXT
  The title of each example is the relative path from the Prawn source examples/ folder.
  
  The first body of text is the introdutory text for the example. Generaly it is a short text describing a feature the example illustrates.
  
  Next comes the example source code in fixed width font. Most of the examples illustrate features that alter the page in place. The effect of these examples is shown right below a dashed line.
  
  Some examples illustrate features that are not suitable to be ran inside this document so they are better left for you to run on your local machine.
  END_TEXT
  
  start_new_page
  load_package "document"
  
  start_new_page
  load_package "graphics"
  
  start_new_page
  load_package "text"
end
