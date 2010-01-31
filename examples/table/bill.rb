# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("bill.pdf") do 

  self.font_size = 9

  Widths = [50, 90, 170, 90, 90, 50]
  Headers = ["Date", "Patient Name", "Description", "Charges / Payments", 
             "Patient Portion Due", "Balance"]

  head = make_table([Headers]) do |t|
    t.column_widths = Widths
    t.cells.background_color = 'cccccc'
  end

  data = []

  def row(date, pt, charges, portion_due, balance)
    rows = charges.map { |c| ["", "", c[0], c[1], "", ""] }
    rows[0][0] = date
    rows[0][1] = pt
    rows[-1][4] = portion_due
    rows[-1][5] = balance

    make_table(rows) do |t|
      t.column_widths = Widths
      t.cells.style :borders => [], :padding => 2
    end
  end

  data << row("1/1/2010", "", [["Balance Forward", ""]], "0.00", "0.00")
  50.times do
    data << row("1/1/2010", "John", [["Foo", "Bar"], 
                                     ["Foo", "Bar"]], "5.00", "0.00")
  end


  # Wrap head and each data element in an Array -- the outer table has only one
  # column.
  table([[head], *(data.map{|d| [d]})], :header => true)

end
