require "#{File.dirname(__FILE__)}/../example_helper.rb"

builder = Prawn::DocumentBuilder.new

builder.line([100,100], [200,200])
builder.stroke
builder.start_new_page(:layout => :landscape)
builder.line([10,100], [300,300])
builder.stroke

document = builder.compile
document.render_file("simple.pdf")

last_page = builder.commands.select { |c| c.name == :new_page }.last
builder.commands.delete(last_page)

last_line = builder.commands.select { |c| c.name == :line }.last
last_line.params[:point1] = [200,100]
last_line.params[:point2] = [100,200]

document = builder.compile
document.render_file("simple-mod.pdf")










