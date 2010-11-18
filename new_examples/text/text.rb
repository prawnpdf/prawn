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
                    "text_box_excess"
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
                              "rendering_and_color"
                            ]
      ],
      [ "External Fonts", [ "single_usage",
                            "registering_families"
                          ]
      ]
    ]
  )
end
