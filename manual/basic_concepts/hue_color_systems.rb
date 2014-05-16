# encoding: utf-8
#
# Colors may be specified in a more intuitive manner using one of the
# CSS hue-oriented functions: <code>hsl()</code> and
# <code>hwb()</code>.  Rather than setting individual color channel
# components, as you do in RGB or CMYK, these color systems let you
# indicate the basic <i>hue</i> (the position around the color wheel)
# and then modify it in ways such as how light or dark or vivid the
# color should be.
#
# <b>HSL</b> colors have three components: the <i>hue</i> (the pure color),
# the <i>saturation</i> (vividness or grayness), and <i>lightness</i>
# (how dark or light).
#
# <b>HWB</b> colors also have three components: the <i>hue</i>, and
# then a percentage of <i>whiteness</i> and <i>blackness</i>.  You can
# think of the last two as if you are diluting the pure hue color with
# some amount of white and/or black paint, to produce tints or shades.
# If the percent white + black to add reaches 100% then it overwhelms
# the hue and you get gray.
#
# Both HSL and HWB let you specify the hue the same way, and it is
# generally defined in degrees, 0 to 360, going around a color wheel
# as shown below. You can also use various English color names and
# adjectives to indicate the hue component.

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  w = 550
  dh = 15
  num_h = 360/dh
  h_w = w / num_h

  self.line_width = 0

  q = Math::PI * 2 / 360  # convert degrees into radians

  translate( 270, 275 ) do
    num_h.times do |i_h|
      hue = i_h * dh
      d0 = hue - dh/2.0
      d1 = hue + dh/2.0

      d0sin, d0cos = [Math.sin(d0*q), Math.cos(d0*q)]
      d1sin, d1cos = [Math.sin(d1*q), Math.cos(d1*q)]
      dmsin, dmcos = [Math.sin(hue*q), Math.cos(hue*q)]

      12.times do |z|
        sat = 30 + 70 * (z/12.0)
        light = 85 - 40 * (z/12.0)
        fill_color "hsl(#{ hue },#{ sat }%,#{ light }%)"
        r0 = 30 + z*10
        r1 = r0 + 10
        fill_polygon [d0cos*r0,d0sin*r0], [d0cos*r1,d0sin*r1], [d1cos*r1,d1sin*r1], [d1cos*r0,d1sin*r0]
      end

      fill_color 'black'
      rotate( hue, :origin=>[0,0] ) do
        draw_text "#{ hue }\u00B0", :at => [120, -5]
      end
    end

    hues = ["red","reddish orange","red orange","orangish red",
            "orange", "yellowish orange", "yellow orange", "orangish yellow",
            "yellow", "yellowish green", "yellow green", "greenish yellow",
            "green", "bluish green", "blue green", "greenish blue",
            "blue", "purplish blue", "blue purple", "bluish purple",
            "purple", "reddish purple", "purple red", "purplish red"]
    hues.each do |huename|
      color = CSSColor.new "hsl(#{ huename },100%,50%)"
      hue = color.hue
      rotate( hue, :origin=>[0,0] ) do
        draw_text "#{ huename }", :at => [160,-5], :size=>9
      end
    end

  end

end
