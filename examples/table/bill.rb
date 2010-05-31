# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("bill.pdf") do 

  self.font_size = 9

  Widths = [50, 90, 170, 90, 90, 50]
  Headers = ["Date", "Patient Name", "Description", "Charges / Payments", 
             "Patient Portion Due", "Balance"]

  head = make_table([Headers], :column_widths => Widths)

  data = []

  def row(date, pt, charges, portion_due, balance)
    rows = charges.map { |c| ["", "", c[0], c[1], "", ""] }

    # Date and Patient Name go on the first line.
    rows[0][0] = date
    rows[0][1] = pt

    # Due and Balance go on the last line.
    rows[-1][4] = portion_due
    rows[-1][5] = balance

    # Return a Prawn::Table object to be used as a subtable.
    make_table(rows) do |t|
      t.column_widths = Widths
      t.cells.style :borders => [:left, :right], :padding => 2
      t.columns(4..5).align = :right
    end

  end

  data << row("1/1/2010", "", [["Balance Forward", ""]], "0.00", "0.00")
  50.times do
    data << row("1/1/2010", "John", [["Foo", "Bar"], 
                                     ["Foo", "Bar"]], "5.00", "0.00")
  end


  # Wrap head and each data element in an Array -- the outer table has only one
  # column.
  table([[head], *(data.map{|d| [d]})], :header => true,
        :row_colors => %w[cccccc ffffff]) do
    
    row(0).style :background_color => '000000', :text_color => 'ffffff'
    cells.style :borders => []
  end

end
