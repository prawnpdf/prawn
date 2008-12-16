# encoding: utf-8
#
# Some text is not usefully wrapped by our naive_wrap which depends on 
# spaces.  This example shows how to wrap by character instead.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

start = Time.now
Prawn::Document.generate("chinese_flow.pdf") do  
  font "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"   
  text_options.update(:wrap => :character, :size => 16)
  long_text = "更可怕的是，同质化竞争对手可以按照URL中后面这个ID来遍历您的DB中的内容，写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事，这样的话，你就非常被动了。写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事"                                                       
  text long_text
  
  # be sure to restore space based wrapping when dealing with latin scripts
  text_options.update(:wrap => :spaces)
  long_text = "Text with some spaces " * 25
  text long_text
end