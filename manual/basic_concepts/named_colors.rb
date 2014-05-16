# encoding: utf-8
#
# Many colors may be specified using a simple English name.  All
# the CSS color names are recognized, both the base colors and the
# extended X11 colors.  Also, generally, "gray" may be spelled "grey".

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  colors = Prawn::CSSColor::CSS_NAMED_COLORS
  cnames = colors.keys

  num_cols = 3
  num_rows = (cnames.length + num_cols - 1) / num_cols

  rows = []
  num_rows.times.each do |rownum|
    row = []
    num_cols.times.each do |colnum|
      idx = rownum + colnum * num_rows
      if idx < cnames.length
        cname = cnames[idx]
        color = colors[ cname ]
        row.push( {:content=>'', :background_color=>color} )
        row.push( cname )
      else
        row.push('')
        row.push('')
      end
    end
    rows.push( row )
  end

  table( rows, :position => :center, :column_widths => [30, 130] * num_cols ) do
    column(1).style :borders => []
    column(3).style :borders => []
    column(5).style :borders => []
  end

end
