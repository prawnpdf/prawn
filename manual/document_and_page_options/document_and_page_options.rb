# encoding: utf-8
#
# Examples for stamps and repeaters.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::ManualBuilder::Example.generate("document_and_page_options.pdf",
                        :page_size => "FOLIO") do

  package "document_and_page_options" do |p|

    p.example "page_size",    :eval_source => false, :full_source => true
    p.example "page_margins", :eval_source => false, :full_source => true
    p.example "background",   :eval_source => false, :full_source => true
    p.example "metadata",     :eval_source => false, :full_source => true
    p.example "print_scaling",:eval_source => false, :full_source => true

    p.intro do
      prose("So far we've already seen how to create new documents and start new pages. This chapter expands on the previous examples by showing other options avialable. Some of the options are only available when creating new documents.

      The examples show:")

      list( "How to configure page size",
            "How to configure page margins",
            "How to use a background image",
            "How to add metadata to the generated PDF"
          )
    end

  end
end
