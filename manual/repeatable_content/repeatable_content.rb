# encoding: utf-8
#
# Examples for stamps and repeaters.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::ManualBuilder::Example.generate("repeatable_content.pdf", :page_size => "FOLIO") do
  package "repeatable_content" do |p|
    p.example "repeater",       :eval_source => false
    p.example "stamp"
    p.example "page_numbering", :eval_source => false
    p.example "alternate_page_numbering", :eval_source => false

    p.intro do
      prose("Prawn offers two ways to handle repeatable content blocks. Repeater is useful for content that gets repeated at well defined intervals while Stamp is more appropriate if you need better control of when to repeat it.

      There is also one very specific helper for numbering pages.

      The examples show:")

      list( "How to repeat content on several pages with a single invocation",
            "How to create a new Stamp",
            'How to "stamp" the content block on the page',
            "How to number the document pages with one simple call"
          )
    end
  end
end
