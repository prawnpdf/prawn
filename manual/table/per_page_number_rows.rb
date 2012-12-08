# encoding: utf-8
#
# To know how many rows are display per page, you can use <code>per_page_number_rows</code>
# It will be easier to display total per page
#

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  data = [["The quick brown fox jumped over the lazy dogs."]] * 100

  t = table data
  t.per_page_number_rows

  # Result is : [33,33,33,1]
  # 33 is the number of rows in first page
  # 33 is the number of rows in second page
  # 33 is the number of rows in thirs page
  # 1 is the number of rows in the last page


  # Now you can display total in bottom of each page
  pdf.page_count.times do |i|
    pdf.go_to_page(i+1)
    total_price = data[t.per_page_number_rows[0,i].sum,t.per_page_number_rows[i]].sum{|s| s[5]}
    pdf.text "Total Price : #{total_price}"
  end

end



