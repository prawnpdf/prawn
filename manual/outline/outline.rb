# encoding: utf-8
#
# Examples for defining the document outline.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::ManualBuilder::Example.generate("outline.pdf", :page_size => "FOLIO") do
  package "outline" do |p|
    p.section "Basics" do |s|
      s.example "sections_and_pages", :eval_source => false
    end

    p.section "Adding nodes later" do |s|
      s.example "add_subsection_to",    :eval_source => false
      s.example "insert_section_after", :eval_source => false
    end

    p.intro do
      prose("The outline of a PDF document is the table of contents tab you see to the right or left of your PDF viewer.

      The examples include:")

      list( "How to define sections and pages",
            "How to insert sections and/or pages to a previously defined outline structure"
          )
    end
  end
end
