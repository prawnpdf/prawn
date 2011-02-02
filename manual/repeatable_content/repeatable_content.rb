# encoding: utf-8
#
# Examples for stamps.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("repeatable_content.pdf") do
  build_package("repeatable_content", [
      [ "Basics", [ {:name => "repeater", :eval_source => false},
                    "stamp"
                  ]
      ]
    ]
    
  ) do
    text "Prawn offers two ways to handle repeatable content blocks. Repeater is useful for content that gets repeated at well defined intervals while Stamp is more appropriate if you need better control of when to repeat it.

    The examples show:"

    list( "How to repeat content on several pages with a single invocation",
          "How to create a new Stamp",
          'How to "stamp" the content block on the page'
        )
  end
end
