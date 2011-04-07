# encoding: utf-8
#
# Examples for stamps and repeaters.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("document_and_page_options.pdf") do
  build_package("document_and_page_options", [
      {:name => "page_size",    :eval_source => false, :full_source => true},
      {:name => "page_margins", :eval_source => false, :full_source => true},
      {:name => "background",   :eval_source => false, :full_source => true},
      {:name => "metadata",     :eval_source => false, :full_source => true}
    ]
    
  ) do
    text "So far we've already seen how to create new documents and start new pages. This chapter expands on the previous examples by showing the options avialable. Some of the options are only available when creating new documents.

    The examples show:"

    list( "How to configure page size",
          "How to configure page margins",
          "How to use a background image",
          "How to add metadata to the generated PDF"
        )
  end
end
