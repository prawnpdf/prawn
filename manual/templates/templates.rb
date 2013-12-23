# encoding: utf-8
#
# Examples for loading existing pdfs.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("templates.pdf", :page_size => "FOLIO") do
  
  package "templates" do |p|
    
    p.example "full_template", :eval_source => false, :full_source => true
    p.example "page_template"
    
    p.intro do
      prose("<b>NOTE: Templates are currently unmaintained and may be removed by Prawn 1.0!</b>")
      prose("Templates let you embed other PDF documents inside the current one.

      The examples show:")

      list( "How to load the whole content from another PDF",
            "How to load single pages from another PDF"
          )
    end
    
  end
end
