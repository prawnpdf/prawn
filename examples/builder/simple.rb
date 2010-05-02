require "#{File.dirname(__FILE__)}/../example_helper.rb"

builder = Prawn::DocumentBuilder.new
builder.start_new_page(:layout => :landscape)
builder.start_new_page
builder.start_new_page(:size => "LEGAL")

document = builder.compile
document.render_file("builder.pdf")

builder.commands[-1].options[:size] = "A4"
document = builder.compile
document.render_file("builder-mod.pdf")




