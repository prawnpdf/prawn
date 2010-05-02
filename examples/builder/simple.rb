require "#{File.dirname(__FILE__)}/../example_helper.rb"

builder = Prawn::DocumentBuilder.new

builder.line([100,100], [200,200])
builder.stroke
builder.start_new_page(:layout => :landscape)
builder.line([10,100], [300,300])
builder.stroke
builder.start_new_page
builder.text("The rain in Spain falls mainly on the plains. " * 200)

document = builder.compile
document.render_file("simple.pdf")

# page 1 automatically created for now
page_2 = builder.commands.find { |c| c.name == :new_page }
builder.commands.delete(page_2)

last_line = builder.commands.select { |c| c.name == :line }.last
last_line.params[:point1] = [200,100]
last_line.params[:point2] = [100,200]

text = builder.commands.find { |c| c.name == :text }
text.params[:contents] = "The rain in Spain is subject to change"

document = builder.compile
document.render_file("simple-mod.pdf")
