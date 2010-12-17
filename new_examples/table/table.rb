# encoding: utf-8
#
# Examples for tables.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("table.pdf") do
  build_package("table", [
      [ "Basics", [ "creation",
                    "content_and_subtables",
                    "flow_and_header"
                  ]
      ],
      [ "Table Styling", [ "column_widths",
                           "width",
                           "row_colors",
                           "cell_style",
                           "cell_borders"
                         ]
      ],
      ["Initializer Block", [
                            ]
      ]
    ]
  )
end
