# encoding: utf-8
# 
# Different languages have different line wrapping. Compare Chinese where a
# sentence can break after any character to English where you have to break
# after full words or do some hyphenation.
#
# This example show how Prawn can handle these differences gracefully.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf", :size => 16) do
    text "Let's see some chinese text wrapping:"
    move_down 20
    
    long_text = "更可怕的是，同质化竞争对手可以按照URL中后面这个ID来遍历您的DB中的内容，写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事，这样的话，你就非常被动了。写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事写个小爬虫把你的页面上的关键信息顺次爬下来也不是什么难事"                                                       
    text long_text
    move_down 20
    
    text "Now let's go back to some english text. " + 
         "Did you notice any wrapping difference?"
  end
end
