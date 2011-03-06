# encoding: utf-8
#
# Examples for text rendering.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("text.pdf") do
  build_package("text", [
      [ "Basics", [ "free_flowing_text",
                    "positioned_text",
                    "text_box_overflow",
                    "text_box_excess",
                    "group",
                    "column_box"
                  ]
      ],
      [ "Styling", [ "font",
                     "font_size",
                     "font_style",
                     "alignment",
                     "leading",
                     "kerning_and_character_spacing",
                     "paragraph_indentation",
                     "rotation"
                   ]
      ],
      [ "Advanced Styling", [ "inline",
                              "formatted_text",
                              "formatted_callbacks",
                              "rendering_and_color",
                              "text_box_extensions"
                            ]
      ],
      [ "External Fonts", [ "single_usage",
                            "registering_families"
                          ]
      ],
      [ "M17n", [ "utf8",
                  "line_wrapping",
                  "right_to_left_text",
                  "fallback_fonts"
                ]
      ]
    ]
    
  ) do
    text "This is probably the feature people will use the most. There is no shortage of options when it comes to text. You'll be hard pressed to find a use case that is not covered by one of the text methods and confgurable options.

    The examples show:"

    list( "Text that flows from page to page without the need to start the new pages",
          "How to use text boxes and place them on specific positions",
          "What to do when a text box is too small to fit its content",
          "How to proceed when you want to prevent paragraphs from splitting between pages",
          "Flowing text in columns",
          "How to change the text style configuring font, size, alignment and many other settings",
          "How to style specific portions of a text with inline styling and formatted text",
          "How to define formatted callbacks to reuse common styling definitions",
          "How to use the different rendering modes available for the text methods",
          "How to create your custom text boxe extensions",
          "How to use external fonts on your pdfs",
          "What happens when rendering text in different languages"
        )
  end
end
