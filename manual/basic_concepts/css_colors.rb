# encoding: utf-8
#
# Colors in Prawn are specified using CSS, the same as in HTML or SVG.
# It can understand simple CSS colors like <code>black</code> or
# <code>#A27010</code>, as well as the powerful function-like
# syntaxes.  This allows you to include both RGB and CMYK colors in
# your PDF document. You can even use a variety of other more
# intuitive color spaces such as HSL and HWB, and they will be
# converted into the appropriate PDF color.  For convienience
# Prawn will recognize <code>cmyk()</code> as an alias to the
# official <code>device-cmyk()</code> CSS function.
#
# As well as CSS, Prawn continues to support it's traditional color
# naming syntaxes: a 6-digit hex string like <code>"1077C2"</code> for
# RGB, and for CMYK a Ruby list of four numbers from 0 to 100, like
# <code>[100 0 30 44]</code>.
#
# Almost all of the CSS color syntaxes may be used, even up to CSS Color
# Level 4 (in draft).  However Prawn does not support transparent or
# translucent colors: the special name <code>transparent</code> or any
# color with an alpha value less than 1.0.  It also does not support
# the advanced <code>color()</code> adjustment and blending functions
# proposed in CSS level 4.
#
# Prawn does not provide support for outputting CIE calibrated colors,
# such as ICC or Lab.
#
# For more information about the available ways to name colors in CSS
# see the standards:
#
# CSS Color Module level 3 - http://www.w3.org/TR/css3-color/
#
# CSS Color Module level 4 (draft) - http://dev.w3.org/csswg/css-color-4/
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  ["black", "crimson", "#00CC22", "gray(55%)",
   "rgb(0, 0.2, 0.7)", "rgb(80%, 0, 50%)",
   "cmyk(0.8, 0.25, 0, 0.3)", "cmyk(10%, 30%, 70%, 60%)",
   "hsl(220deg, 80%, 30%)", "hsl(yellowish green, 100%, 40%)",
   "hwb(purple blue, 33.3%, 0.4)",
   "ab7020", [10, 50, 0, 50] ].each do |color|

    text "This is using color: #{color.inspect}", :color => color
    move_down 2.mm
  end
end
