# encoding: utf-8
#
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

start = Time.now
Prawn::Document.generate("chinese_flow.pdf") do  
  font "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"   
  font_size 16

  long_text = "更可怕的是，同质化竞争对手可以按照URL中后面这个ID来遍历您的DB中的内容，写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事，这样的话，你就非常被动了。写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事"                                                       
  text long_text
  
  # be sure to restore space based wrapping when dealing with latin scripts
  long_text = "Text with some spaces " * 25
  text long_text
end
