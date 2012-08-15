# encoding: utf-8
# 
# Inline formatting gives you the option to format specific portions of a text.
# It uses HTML-esque syntax inside the text string. Supported tags are:
# <code>b</code> (bold), <code>i</code> (italic), <code>u</code> (underline),
# <code>strikethrough</code>, <code>sub</code> (subscript), <code>sup</code>
# (superscript)
#
# The following tags accept specific attributes: <code>font</code> accepts
# <code>size</code>, <code>name</code>, and <code>character_spacing</code>;
# <code>color</code> accepts <code>rgb</code> and <code>cmyk</code>;
# <code>link</code> accepts <code>href</code> for external links and
# <code>anchor</code> for internal links.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  %w[b i u strikethrough sub sup].each do |tag|
    text "Just your regular text <#{tag}>except this portion</#{tag}> " +
         "is using the #{tag} tag",
         :inline_format => true
    move_down 10
  end
  
  text "This <font size='18'>line</font> uses " +
       "<font name='Courier'>all the font tag</font> attributes in " +
       "<font character_spacing='2'>a single line</font>. ",
       :inline_format => true
  move_down 10
  
  text "Coloring in <color rgb='FF00FF'>both RGB</color> " +
       "<color c='100' m='0' y='0' k='0'>and CMYK</color>",
       :inline_format => true
  move_down 10
  
  text "This an external link to the " +
       "<u><link href='https://github.com/prawnpdf/prawn/wiki'>Prawn wiki" +
       "</link></u> and this is a link to the " +
       "<u><link anchor='Text Reference'>Text Reference</link></u> anchor",
       :inline_format => true
end
