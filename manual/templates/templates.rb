# encoding: utf-8
#
# Examples for loading existing pdfs.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("templates.pdf") do
  build_package("templates", [
      { :name        => "full_template",
        :eval_source => false,
        :full_source => true
      },
      "page_template"
    ]
    
  ) do
    text "Templates let you embed other PDF documents inside the current one.

    The examples show:"

    list( "How to load the whole content from another PDF",
          "How to load single pages from another PDF"
        )
  end
end
