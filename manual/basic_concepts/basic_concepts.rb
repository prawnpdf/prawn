# encoding: utf-8
#
# Examples for Prawn basic concepts.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("basic_concepts.pdf") do
  build_package("basic_concepts", [
      { :name => "creation", :eval_source => false, :full_source => true },
      "origin",
      "cursor",
      "other_cursor_helpers",
      "adding_pages",
      "measurement"
    ]
    
  ) do
    
    text "This chapter covers the minimum amount of functionality you'll need to start using Prawn.
    
    If you are new to Prawn this is the first chapter to read. Once you are comfortable with the concepts shown here you might want to check the Basics section of the Graphics, Bounding Box and Text sections.
    
    The examples show:"
    
    list( "How to create new pdf documents in every possible way",
          "Where the origin for the document coordinates is. What are Bounding Boxes and how they interact with the origin",
          "How the cursor behaves",
          "How to start new pages",
          "What the base unit for measurement and coordinates is and how to use other convenient measures"
        )
  end
end
