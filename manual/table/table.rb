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
      [ "Styling", [ "column_widths",
                     "width",
                     "row_colors",
                     "cell_dimensions",
                     "cell_borders_and_bg",
                     "cell_text"
                   ]
      ],
      ["Initializer Block", [ "basic_block",
                              "filtering",
                              "style"
                            ]
      ]
    ]

  ) do
    text "Prawn comes with table support out of the box. Tables can be styled in whatever way you see fit. The whole table, rows, columns and cells can be styled independently from each other.

    The examples show:"

    list( "How to create tables",
          "What content can be placed on tables",
          "Subtables (or tables within tables)",
          "How to style the whole table",
          "How to use initializer blocks to style only specific portions of the table"
        )
  end
end
