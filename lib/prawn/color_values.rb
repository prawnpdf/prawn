# encoding: utf-8
#
# color_values.rb : Representation of colors
#
# Copyright May 2014.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn

  # Abstract base class for colors.
  class PDFColor
    # Is the color completely opaque?
    def opaque?
      true
    end

    # Is the color completely transparent?
    def transparent?
      false
    end

    # Returns the PDF color space name
    def color_space
      return :DeviceGray
    end

    # Returns the PDF color value as a string
    def to_pdf
      return '0'
    end

    def ==(other)
      other.is_a?(self.class) && color_space == other.color_space && to_pdf == other.to_pdf
    end


    protected  # Following are utility functions

    # Clamps a float to be within a given range, default 0.0 to 1.0
    def clamp( f, f_min=0.0, f_max=1.0 )
      if f < f_min
        f_min
      elsif f > f_max
        f_max
      else
        f
      end
    end

    # Converts a float to a PDF number. Only keeps 3 significant
    # digits, which is good enough for 8-bits per color channel.
    def f_to_num( n )
      sprintf('%.3f', n).gsub(/\.?0+$/,'')
    end

    # Is the float near zero?
    def eq_zero?( n )
      n < 0.001 && n > -0.001
    end

    # Is the float near zero or less?
    def le_zero?( n )
      n < 0.001
    end

    # Is the float near one or more?
    def ge_one?( n )
      n > 0.999
    end
  end


  # Class for PDF /Pattern colors.
  class PatternColor < PDFColor
    attr_accessor :name
    def initialize( name )
      @name = name
    end
    def color_space
      :Pattern
    end
    def to_pdf
      PDF::Core::PdfObject @name.to_sym
    end
  end


  # Simple class for PDF /DeviceGray colors.
  class GrayColor < PDFColor
    attr_reader :gray
    def initialize( gray=0.0 )
      @gray = clamp(gray)
    end
    def gray=(gray)
      @grap = clamp(gray)
    end
    def color_space
      :DeviceGray
    end
    def to_pdf
      f_to_num(@gray)
    end
  end

  # Simple class for PDF /DeviceRGB colors.
  class RGBColor < PDFColor
    attr_reader :red, :green, :blue
    def initialize( r=0.0, g=0.0, b=0.0 )
      @red = clamp(r)
      @green = clamp(g)
      @blue = clamp(b)
    end
    def rgb
      [@red, @green, @blue]
    end
    def red=(r)
      @red = clamp(r)
    end
    def green=(g)
      @green = clamp(g)
    end
    def blue=(b)
      @blue = clamp(b)
    end
    def color_space
      :DeviceRGB
    end
    def to_pdf
      [f_to_num(@red), f_to_num(@green), f_to_num(@blue)].join(' ')
    end
  end

  # Simple class for PDF /DeviceCMYK colors.
  class CMYKColor < PDFColor
    attr_reader :cyan, :magenta, :yellow, :black
    def initialize( c=0.0, m=0.0, y=0.0, k=0.0 )
      @cyan = clamp(c)
      @magenta = clamp(m)
      @yellow = clamp(y)
      @black = clamp(k)
    end
    def cmyk
      [@cyan, @magenta, @yellow, @black]
    end
    def cyan=(c)
      @cyan = clamp(c)
    end
    def magenta=(m)
      @magenta = clamp(m)
    end
    def yellow=(y)
      @yellow = clamp(y)
    end
    def black=(k)
      @black = clamp(k)
    end
    def color_space
      :DeviceCMYK
    end
    def to_pdf
      [f_to_num(@cyan), f_to_num(@magenta), f_to_num(@yellow), f_to_num(@black)].join(' ')
    end
  end


  # Class for colors that can be specified using CSS syntax.
  # Also handles the syntaxes traditionally used by Prawn,
  # converting them into equivalent CSS colors.
  #
  # See the documentation on the set() method.
  #
  class CSSColor < PDFColor
    CSS_COLOR_TYPES = [:GRAY, :RGB, :CMYK, :HSL, :HWB, :TRANSPARENT]

    # Map of all predefined CSS/SVG color names to their
    # equivalent RGB values.
    CSS_NAMED_COLORS = {
      'aliceblue' => '#F0F8FF',  # 240,248,255
      'antiquewhite' => '#FAEBD7',  # 250,235,215
      'aqua' => '#00FFFF',  # 0,255,255
      'aquamarine' => '#7FFFD4',  # 127,255,212
      'azure' => '#F0FFFF',  # 240,255,255
      'beige' => '#F5F5DC',  # 245,245,220
      'bisque' => '#FFE4C4',  # 255,228,196
      'black' => '#000000',  # 0,0,0
      'blanchedalmond' => '#FFEBCD',  # 255,235,205
      'blue' => '#0000FF',  # 0,0,255
      'blueviolet' => '#8A2BE2',  # 138,43,226
      'brown' => '#A52A2A',  # 165,42,42
      'burlywood' => '#DEB887',  # 222,184,135
      'cadetblue' => '#5F9EA0',  # 95,158,160
      'chartreuse' => '#7FFF00',  # 127,255,0
      'chocolate' => '#D2691E',  # 210,105,30
      'coral' => '#FF7F50',  # 255,127,80
      'cornflowerblue' => '#6495ED',  # 100,149,237
      'cornsilk' => '#FFF8DC',  # 255,248,220
      'crimson' => '#DC143C',  # 220,20,60
      'cyan' => '#00FFFF',  # 0,255,255
      'darkblue' => '#00008B',  # 0,0,139
      'darkcyan' => '#008B8B',  # 0,139,139
      'darkgoldenrod' => '#B8860B',  # 184,134,11
      'darkgray' => '#A9A9A9',  # 169,169,169
      'darkgreen' => '#006400',  # 0,100,0
      'darkgrey' => '#A9A9A9',  # 169,169,169
      'darkkhaki' => '#BDB76B',  # 189,183,107
      'darkmagenta' => '#8B008B',  # 139,0,139
      'darkolivegreen' => '#556B2F',  # 85,107,47
      'darkorange' => '#FF8C00',  # 255,140,0
      'darkorchid' => '#9932CC',  # 153,50,204
      'darkred' => '#8B0000',  # 139,0,0
      'darksalmon' => '#E9967A',  # 233,150,122
      'darkseagreen' => '#8FBC8F',  # 143,188,143
      'darkslateblue' => '#483D8B',  # 72,61,139
      'darkslategray' => '#2F4F4F',  # 47,79,79
      'darkslategrey' => '#2F4F4F',  # 47,79,79
      'darkturquoise' => '#00CED1',  # 0,206,209
      'darkviolet' => '#9400D3',  # 148,0,211
      'deeppink' => '#FF1493',  # 255,20,147
      'deepskyblue' => '#00BFFF',  # 0,191,255
      'dimgray' => '#696969',  # 105,105,105
      'dimgrey' => '#696969',  # 105,105,105
      'dodgerblue' => '#1E90FF',  # 30,144,255
      'firebrick' => '#B22222',  # 178,34,34
      'floralwhite' => '#FFFAF0',  # 255,250,240
      'forestgreen' => '#228B22',  # 34,139,34
      'fuchsia' => '#FF00FF',  # 255,0,255
      'gainsboro' => '#DCDCDC',  # 220,220,220
      'ghostwhite' => '#F8F8FF',  # 248,248,255
      'gold' => '#FFD700',  # 255,215,0
      'goldenrod' => '#DAA520',  # 218,165,32
      'gray' => '#808080',  # 128,128,128
      'green' => '#008000',  # 0,128,0
      'greenyellow' => '#ADFF2F',  # 173,255,47
      'grey' => '#808080',  # 128,128,128
      'honeydew' => '#F0FFF0',  # 240,255,240
      'hotpink' => '#FF69B4',  # 255,105,180
      'indianred' => '#CD5C5C',  # 205,92,92
      'indigo' => '#4B0082',  # 75,0,130
      'ivory' => '#FFFFF0',  # 255,255,240
      'khaki' => '#F0E68C',  # 240,230,140
      'lavender' => '#E6E6FA',  # 230,230,250
      'lavenderblush' => '#FFF0F5',  # 255,240,245
      'lawngreen' => '#7CFC00',  # 124,252,0
      'lemonchiffon' => '#FFFACD',  # 255,250,205
      'lightblue' => '#ADD8E6',  # 173,216,230
      'lightcoral' => '#F08080',  # 240,128,128
      'lightcyan' => '#E0FFFF',  # 224,255,255
      'lightgoldenrodyellow' => '#FAFAD2',  # 250,250,210
      'lightgray' => '#D3D3D3',  # 211,211,211
      'lightgreen' => '#90EE90',  # 144,238,144
      'lightgrey' => '#D3D3D3',  # 211,211,211
      'lightpink' => '#FFB6C1',  # 255,182,193
      'lightsalmon' => '#FFA07A',  # 255,160,122
      'lightseagreen' => '#20B2AA',  # 32,178,170
      'lightskyblue' => '#87CEFA',  # 135,206,250
      'lightslategray' => '#778899',  # 119,136,153
      'lightslategrey' => '#778899',  # 119,136,153
      'lightsteelblue' => '#B0C4DE',  # 176,196,222
      'lightyellow' => '#FFFFE0',  # 255,255,224
      'lime' => '#00FF00',  # 0,255,0
      'limegreen' => '#32CD32',  # 50,205,50
      'linen' => '#FAF0E6',  # 250,240,230
      'magenta' => '#FF00FF',  # 255,0,255
      'maroon' => '#800000',  # 128,0,0
      'mediumaquamarine' => '#66CDAA',  # 102,205,170
      'mediumblue' => '#0000CD',  # 0,0,205
      'mediumorchid' => '#BA55D3',  # 186,85,211
      'mediumpurple' => '#9370DB',  # 147,112,219
      'mediumseagreen' => '#3CB371',  # 60,179,113
      'mediumslateblue' => '#7B68EE',  # 123,104,238
      'mediumspringgreen' => '#00FA9A',  # 0,250,154
      'mediumturquoise' => '#48D1CC',  # 72,209,204
      'mediumvioletred' => '#C71585',  # 199,21,133
      'midnightblue' => '#191970',  # 25,25,112
      'mintcream' => '#F5FFFA',  # 245,255,250
      'mistyrose' => '#FFE4E1',  # 255,228,225
      'moccasin' => '#FFE4B5',  # 255,228,181
      'navajowhite' => '#FFDEAD',  # 255,222,173
      'navy' => '#000080',  # 0,0,128
      'oldlace' => '#FDF5E6',  # 253,245,230
      'olive' => '#808000',  # 128,128,0
      'olivedrab' => '#6B8E23',  # 107,142,35
      'orange' => '#FFA500',  # 255,165,0
      'orangered' => '#FF4500',  # 255,69,0
      'orchid' => '#DA70D6',  # 218,112,214
      'palegoldenrod' => '#EEE8AA',  # 238,232,170
      'palegreen' => '#98FB98',  # 152,251,152
      'paleturquoise' => '#AFEEEE',  # 175,238,238
      'palevioletred' => '#DB7093',  # 219,112,147
      'papayawhip' => '#FFEFD5',  # 255,239,213
      'peachpuff' => '#FFDAB9',  # 255,218,185
      'peru' => '#CD853F',  # 205,133,63
      'pink' => '#FFC0CB',  # 255,192,203
      'plum' => '#DDA0DD',  # 221,160,221
      'powderblue' => '#B0E0E6',  # 176,224,230
      'purple' => '#800080',  # 128,0,128
      'red' => '#FF0000',  # 255,0,0
      'rosybrown' => '#BC8F8F',  # 188,143,143
      'royalblue' => '#4169E1',  # 65,105,225
      'saddlebrown' => '#8B4513',  # 139,69,19
      'salmon' => '#FA8072',  # 250,128,114
      'sandybrown' => '#F4A460',  # 244,164,96
      'seagreen' => '#2E8B57',  # 46,139,87
      'seashell' => '#FFF5EE',  # 255,245,238
      'sienna' => '#A0522D',  # 160,82,45
      'silver' => '#C0C0C0',  # 192,192,192
      'skyblue' => '#87CEEB',  # 135,206,235
      'slateblue' => '#6A5ACD',  # 106,90,205
      'slategray' => '#708090',  # 112,128,144
      'slategrey' => '#708090',  # 112,128,144
      'snow' => '#FFFAFA',  # 255,250,250
      'springgreen' => '#00FF7F',  # 0,255,127
      'steelblue' => '#4682B4',  # 70,130,180
      'tan' => '#D2B48C',  # 210,180,140
      'teal' => '#008080',  # 0,128,128
      'thistle' => '#D8BFD8',  # 216,191,216
      'tomato' => '#FF6347',  # 255,99,71
      'turquoise' => '#40E0D0',  # 64,224,208
      'violet' => '#EE82EE',  # 238,130,238
      'wheat' => '#F5DEB3',  # 245,222,179
      'white' => '#FFFFFF',  # 255,255,255
      'whitesmoke' => '#F5F5F5',  # 245,245,245
      'yellow' => '#FFFF00',  # 255,255,0
      'yellowgreen' => '#9ACD32',  # 154,205,50
    }

    # Map from "base hue" name to degrees (for HSL and HWB color types)
    CSS_BASE_HUES = {
      'red' => 0.0, 'orange' => 30.0, 'yellow' => 60.0,
      'green' => 120.0, 'blue' => 240.0, 'purple' => 300.0,
    }

    # Map from "splash hue" name to degrees (for HSL and HWB color types)
    CSS_SPLASH_HUES = {
      'reddish' => 0.0, 'orangish' => 30.0, 'yellowish' => 60.0,
      'greenish' => 120.0, 'bluish' => 240.0, 'purplish' => 300.0,
    }


    def initialize( color_name='transparent' )
      @ct = :TRANSPARENT
      @alpha = 0.0   # 0.0 = transparent .. 1.0 = opaque
      @comp = {}  # components, dependent on the color type
      set( color_name ) if color_name
    end

    # Is this color completely transparent?
    def transparent?
      @ct == :TRANSPARENT || @alpha == 0.0
    end

    # Is this color completely opaque?
    def opaque?
      @ct != :TRANSPARENT && @alpha == 1.0
    end

    # Returns the alpha channel (0.0 to 1.0)
    def alpha
      @alpha
    end

    # Sets the alpha channel (0.0 to 1.0)
    def alpha=(a)
      if @ct == :TRANSPARENT
        raise ArgumentError, "Alpha channel may not be set on transparent color"
      else
        @alpha = clamp(parse_num_or_pct(a))
      end
    end

    # Returns the gray channel (0.0=black to 1.0=white)
    def gray
      @comp[:gray] if @ct == :GRAY
    end

    # Sets the gray channel (0.0=black to 1.0=white)
    def gray=(gray)
      n = clamp(parse_num_or_pct(gray))
      case @ct
      when :GRAY
        @comp[:gray] = n
      when :RGB
        [:r,:g,:b].each {|s| @comp[s] = n}
      when :CMYK
        [:c,:m,:y,:k].each {|s| @comp[s] = n}
      else
        raise ArgumentError, "Gray level may not be set on #{@ct} color"
      end
    end

    # Returns the tuple [red, blue, green]
    def rgb
      case @ct
      when :RGB, :HSL, :HWB
        [@comp[:r], @comp[:g], @comp[:b]]
      end
    end

    # The red channel (0.0 to 1.0)
    def red
      case @ct
      when :RGB, :HSL, :HWB
        @comp[:r]
      end
    end

    # Sets the red channel (0.0 to 1.0)
    def red=(value)
      if @ct==:RGB
        @comp[:r] = clamp(parse_num_or_pct(value))
      else
        raise ArgumentError, "Red channel may not be set on #{@ct} color"
      end
    end

    # The green channel (0.0 to 1.0)
    def green
      case @ct
      when :RGB, :HSL, :HWB
        @comp[:g]
      end
    end

    # Sets the green channel (0.0 to 1.0)
    def green=(value)
      if @ct==:RGB
        @comp[:g] = clamp(parse_num_or_pct(value))
      else
        raise ArgumentError, "Green channel may not be set on #{@ct} color"
      end
    end

    # The blue channel (0.0 to 1.0)
    def blue
      case @ct
      when :RGB, :HSL, :HWB
        @comp[:b]
      end
    end

    # Sets the blue channel (0.0 to 1.0)
    def blue=(value)
      if @ct==:RGB
        @comp[:b] = clamp(parse_num_or_pct(value))
      else
        raise ArgumentError, "Blue channel may not be set on #{@ct} color"
      end
    end

    # Returns the tuple [cyan, magenta, yellow, black]
    def cmyk
      [@comp[:c], @comp[:m], @comp[:y], @comp[:k]] if @ct == :CMYK
    end

    # The cyan channel (0.0 to 1.0)
    def cyan
      @comp[:c] if @ct == :CMYK
    end

    # Sets the cyan channel (0.0 to 1.0)
    def cyan=(value)
      if @ct==:CMYK
        @comp[:c] = clamp(parse_num_or_pct(value))
      else
        raise ArgumentError, "Cyan channel may not be set on #{@ct} color"
      end
    end

    # The magenta channel (0.0 to 1.0)
    def magenta
      @comp[:m] if @ct == :CMYK
    end

    # Sets the magenta channel (0.0 to 1.0)
    def magenta=(value)
      if @ct==:CMYK
        @comp[:m] = clamp(parse_num_or_pct(value))
      else
        raise ArgumentError, "Magenta channel may not be set on #{@ct} color"
      end
    end

    # The yellow channel (0.0 to 1.0)
    def yellow
      @comp[:y] if @ct == :CMYK
    end

    # Sets the yellow channel (0.0 to 1.0)
    def yellow=(value)
      if @ct==:CMYK
        @comp[:y] = clamp(parse_num_or_pct(value))
      else
        raise ArgumentError, "Yellow channel may not be set on #{@ct} color"
      end
    end

    # The black channel (0.0 to 1.0)
    def black
      case @ct
      when :GRAY
        1.0 - @comp[:gray]
      when :CMYK
        @comp[:k]
      end
    end

    # Sets the black channel (0.0 to 1.0)
    def black=(value)
      n = clamp(parse_num_or_pct(value))
      case @ct
      when :GRAY
        @comp[:gray] = 1.0 - n
      when :CMYK
        @comp[:k] = n
      else
        raise ArgumentError, "Black channel may not be set on #{@ct} color"
      end
    end

    # Returns the tuple [hue, saturation, lightness]
    def hsl
      [@comp[:hue], @comp[:sat], @comp[:lite]] if @ct == :HSL
    end

    # Returns the tuple [hue, whiteness, blackness]
    def hwb
      [@comp[:hue], @comp[:wht], @comp[:blk]] if @ct == :HWB
    end

    # Returns the hue in degrees (0 to 360)
    def hue
      @comp[:hue] if @ct == :HSL or @ct == :HWB
    end

    # Sets the hue, either a number 0 to 260 or a hue name
    def hue=(h)
      case @ct
      when :HSL, :HWB
        @comp[:hue] = parse_css_hue(h)
        recompute_rgb
      else
        raise ArgumentError, "Hue may not be set on #{@ct} color"
      end
    end

    # The saturation (0=gray to 1=vivid)
    def saturation
      case @ct
      when :GRAY
        0.0
      when :HSL
        @comp[:sat]
      end
    end

    # Sets the saturation (0=gray to 1=vivid)
    def saturation=(value)
      if @ct==:HSL
        @comp[:sat] = clamp(parse_num_or_pct(value))
        recompute_rgb
      else
        raise ArgumentError, "Saturation may not be set on #{@ct} color"
      end
    end

    # The lightness (0=black to 1=white)
    def lightness
      case @ct
      when :GRAY
        @comp[:gray]
      when :HSL
        @comp[:lite]
      end
    end

    # Sets the lightness (0=black to 1=white)
    def lightness=(value)
      if @ct==:HSL
        @comp[:lite] = clamp(parse_num_or_pct(value))
        recompute_rgb
      else
        raise ArgumentError, "Lightness may not be set on #{@ct} color"
      end
    end

    # The whiteness dilution (0=pure color to 1=all white)
    def whiteness
      case @ct
      when :GRAY
        @comp[:gray]
      when :HWB
        @comp[:wht]
      end
    end

    # Sets the whiteness dilution (0=pure color to 1=all white)
    def whiteness=(value)
      n = clamp(parse_num_or_pct(value))
      case @ct
      when :GRAY
        @comp[:gray] = n
      when :HWB
        @comp[:wht] = n
        normalize_hwb
        recompute_rgb
      else
        raise ArgumentError, "Whiteness may not be set on #{@ct} color"
      end
    end

    # The blackness dilution (0=pure color to 1=all black)
    def blackness
      case @ct
      when :GRAY
        1.0 - @comp[:gray]
      when :HWB
        @comp[:blk]
      end
    end

    # Sets the blackness dilution (0=pure color to 1=all black)
    def blackness=(value)
      n = clamp(parse_num_or_pct(value))
      case @ct
      when :GRAY
        @comp[:gray] = 1.0 - n
      when :HWB
        @comp[:wht] = n
        normalize_hwb
        recompute_rgb
      else
        raise ArgumentError, "Blackness may not be set on #{@ct} color"
      end
    end

    # Is this color white?
    def white?
      return false if @alpha < 1.0
      case @ct
      when :TRANSPARENT
        false
      when :GRAY
        @comp[:gray] == 1.0
      when :RGB
        @comp[:r] == 1.0 && @comp[:g] == 1.0 && @comp[:b] == 1.0
      when :HSL
        @comp[:lite] == 1.0
      when :HWB
        @comp[:wht] == 1.0 && @comp[:blk] == 0
      when :CMYK
        @comp[:k] == 1.0
      end
    end

    # Is this color black?
    def black?
      return false if @alpha < 1.0
      case @ct
      when :TRANSPARENT
        false
      when :GRAY
        @comp[:gray] == 0
      when :RGB
        @comp[:r] == 0 && @comp[:g] == 0 && @comp[:b] == 0
      when :HSL
        @comp[:lite] == 0
      when :HWB
        @comp[:wht] == 0 && @comp[:blk] == 1.0
      when :CMYK
        @comp[:k] == 0
      end
    end

    # Is this color achromatic (white, gray, or black)
    def gray?
      case @ct
      when :TRANSPARENT
        false
      when :GRAY
        true
      when :RGB,
        @comp[:r] == @comp[:g] && @comp[:g] == @comp[:b]
      when :HSL
        @comp[:sat] == 0.0
      when :HWB
        @comp[:wht] + @comp[:blk] >= 1.0
      when :CMYK
        @comp[:c] == @comp[:m] && @comp[:m] == @comp[:y]
      end
    end

    # The CSS color type
    def color_type
      @ct
    end

    # The PDF color space used to represent this color
    def color_space
      case @ct
      when :GRAY
        :DeviceGray
      when :RGB, :HSL, :HWB
        :DeviceRGB
      when :CMYK
        :DeviceCMYK
      when :TRANSPARENT
        nil
      end
    end

    # The color as a CSS string, using '#RRGGBB' format for RGB, HSL,
    # HWB, and GRAY colors.
    def to_hexcss
      case @ct
      when :RGB, :HSL, :HWB
        s = "#%02x%02x%02x" % [@comp[:r]*255, @comp[:g]*255, @comp[:b]*255 ]
        s = s + "%02x" % (@alpha*255) if @alpha < 1.0
        s
      when :GRAY
        v = @comp[:gray]
        s = "%02x%02x%02x" % [v,v,v]
      else
        to_css
      end
    end

    # The color as a CSS string, using functional notation
    def to_css
      case @ct
      when :TRANSPARENT
        'transparent'
      when :GRAY
        "gray(%s)" % f_to_pct(@comp[:gray])
      when :RGB
        s = [:r,:g,:b].collect{|s| f_to_pct(@comp[s]) }.join(',')
        if @alpha < 1.0
          "rgba(%s,%s)" % [s, f_to_pct(@alpha)]
        else
          "rgb(%s)" % s
        end
      when :HSL
        hue = f_to_num(@comp[:hue])
        s = [:sat,:lite].collect{|s| f_to_pct(@comp[s]) }.join(',')
        if @alpha < 1.0
          "hsla(%sdeg,%s,%s)" % [hue, s, f_to_pct(@alpha)]
        else
          "hsl(%sdeg,%s)" % [hue, s]
        end
      when :HWB
        hue = f_to_num(@comp[:hue])
        s = [:wht,:blk].collect{|s| f_to_pct(@comp[s]) }.join(',')
        if @alpha < 1.0
          "hwb(%sdeg,%s,%s)" % [hue, s, f_to_pct(@alpha)]
        else
          "hwb(%sdeg,%s)" % [hue, s]
        end
      when :CMYK
        s = [:c,:m,:y,:k].collect{|s| f_to_pct(@comp[s]) }.join(',')
        if @alpha < 1.0
          "device-cmyk(%s,%s)" % [s, f_to_pct(@alpha)]
        else
          "device-cmyk(%s)" % s
        end
      end
    end

    # The PDF representation of the color's components
    def to_pdf
      case @ct
      when :TRANSPARENT
        ''
      when :GRAY
        f_to_num( @comp[:gray] )
      when :RGB, :HSL, :HWB
        [:r, :g, :b].collect{ |s| f_to_num(@comp[s]) }.join(' ')
      when :CMYK
        [:c, :m, :y, :k].collect{ |s| f_to_num(@comp[s]) }.join(' ')
      end
    end


    # Sets the color based on the given CSS string value
    #
    # The color string may be any of:
    #
    #   <name>    - a known color name, like "white"
    #
    #   0088FF    - a 6-hex-digit RGB color, in RRGGBB
    #   #08F      - a CSS 3-digit RGB color. Note #17F == #1177FF
    #   #0168AF   - a CSS 6-digit RGB color RRGGBB
    #
    #   gray(V) - A gray where V is a number 0 (black) to 1 (white),
    #                or a percentage 0% to 100%
    #
    #   rgb(R,G,B) - an RGB color, where R,G, and B are either
    #                numbers 0 to 255, or percentages 0% to 100%
    #
    #   cmyk(C,M,Y,K) - A CMYK color where each component is a
    #                number 0.0 to 1.0, or a percentage 0% to 100%
    #
    #   device-cmyk(C,M,Y,K) - Alias for cmyk(C,M,Y,K)
    #
    #   hsl(H,S,L) - an HSL color, where H is a hue; and S and L are
    #                numbers 0 to 1, or percentages 0% to 100%
    #
    #   hwb(H,W,B) - an HWB color, where H is a hue; and W and B are
    #                numbers 0 to 1, or percentages 0% to 100%
    #
    # HUE: For the HSL and HWB functions, the hue is typically an
    # angle in degrees, a number from 0 to 360.  However all the CSS 4
    # hue names may also be used, such as "orange", "blue green",
    # "yellowish green", and even "reddish(30%) orange".
    #
    # The transparent and alpha-channel CSS syntax is also accepted
    # and parsed by this class; however the rest of Prawn is unable
    # to use such non-opaqe colors.
    #
    def set(name)
      if name.is_a? Array
        # Traditional Prawn way to represent a CMYK color is an array
        # of four numbers, each 0 to 100.
        if name.length != 4
          raise ArgumentError, 'CMYK array must have four components'
        end
        @ct = :CMYK
        @alpha = 1.0
        c, m, y, k = name.collect { |n| clamp( n / 100.0 ) }
        @comp = {:c=>c, :m=>m, :y=>y, :k=>k}
        return
      end

      # Have a string.  CSS colors are always case-insensitive.
      name = name.to_s if name.is_a? Symbol
      name = name.strip.downcase

      # Look up known color names first and covert to equivalent color.
      # Also catch "black" and "white" early and force to grayscale.
      name = case name
             when "black", "#000000"
               "gray(0)"
             when "white", "#ffffff"
               "gray(1)"
             else
               CSS_NAMED_COLORS.fetch(name,name)
             end

      if name.empty?
        raise ArgumentError, 'color name is blank'

      elsif name == 'transparent'
        @ct = :TRANSPARENT
        @alpha = 0.0
        @comp = {}

      elsif name =~ /^[0-9a-fA-F]{6}$/
        # Exactly six hex digits with no '#' prefix.
        # This is Prawn's traditional RGB syntax.
        r,g,b = name.chars.each_slice(2).map{ |a,b| (a+b).to_i(16) / 255.0 }
        @ct = :RGB
        @alpha = 1.0
        @comp = {:r => r, :g => g, :b => b}

      elsif name =~ /^\#[0-9a-fA-F]+$/
        # Hex RGB color (3,4,6, or 8 digits) with '#' prefix
        hex = name[1..-1].chars
        if name.length == (1+3)     #RGB
          r,g,b = hex.map{ |c| (c+c).to_i(16) / 255.0 }
          a = 1.0
        elsif name.length == (1+4)  #RGBA
          r,g,b,a = hex.map{ |c| (c+c).to_i(16) / 255.0 }
        elsif name.length == (1+6)  #RRGGBB
          r,g,b = hex.each_slice(2).map{ |a,b| (a+b).to_i(16) / 255.0 }
          a = 1.0
        elsif name.length == (1+8)  #RRGGBBAA
          r,g,b,a = hex.each_slice(2).map{ |a,b| (a+b).to_i(16) / 255.0 }
        else
          raise ArgumentError, "not a valid RGB hex color #{name.inspect}"
        end
        @ct = :RGB
        @alpha = a
        @comp = {:r => r, :g => g, :b => b}

      elsif name =~ /^[[:alpha:]]+\(.*\)$/
        # A CSS functional color specification:  xyz(...)
        cfunc, cparts = name.match( /^([[:alpha:]]+)\((.*)\)/ )[1..2]
        cparts = cparts.split(',').collect{ |part| part.strip }

        if cfunc == 'gray' || cfunc == 'grey'
          if cparts.length != 1
            raise ArgumentError, "gray() color must have one or two components"
          end
          g = clamp( parse_num_or_pct(cparts[0]) )
          a = cparts.length==1 ? 1.0 : clamp( parse_num_or_pct(cparts[1]) )
          @ct = :GRAY
          @comp = {:gray => g}
          @alpha = a

        elsif cfunc == 'rgb' || cfunc == 'rgba'
          if cfunc == 'rgb' &&  cparts.length != 3
            raise ArgumentError, "rgb() color must have three components"
          elsif cfunc == 'rgba' &&  cparts.length != 4
            raise ArgumentError, "rgba() color must have four components"
          end
          r, g, b = cparts[0..2].collect { |s| clamp( parse_num_or_pct(s, 255.0) ) }
          a = cfunc == 'rgb' ? 1.0 : clamp( parse_num_or_pct(cparts[3]) )
          @ct = :RGB
          @comp = {:r => r, :g => g, :b => b}
          @alpha = a

        elsif ['hsl','hsla','hwb'].include? cfunc
          if cfunc=='hsl' && cparts.length != 3
            raise ArgumentError, "#{cfunc}() color must have three components"
          elsif cfunc=='hsla' && cparts.length != 4
            raise ArgumentError, "#{cfunc}() color must have four components"
          elsif cfunc=='hwb' && (cparts.length < 3 || cparts.length > 4)
            raise ArgumentError, "#{cfunc}() color must have three or four components"
          end
          hue = parse_css_hue( cparts[0] )
          nparts = cparts[1..-1].collect{ |s| parse_num_or_pct(s) } # Don't clamp for HWB
          @alpha = nparts.length == 2 ? 1.0 : nparts[2]
          if ['hsl','hsla'].include? cfunc
            @ct = :HSL
            @comp = {:hue => hue, :sat => clamp(nparts[0]), :lite => clamp(nparts[1])}
          else
            @ct = :HWB
            @comp = {:hue => hue, :wht => nparts[0], :blk => nparts[1]}
            normalize_hwb  # adjust so (wht + blk) <= 100%
          end
          recompute_rgb   # Compute RGB equivalent color

        elsif cfunc == 'device-cmyk' || cfunc == 'cmyk'
          if cparts.length < 4
            raise ArgumentError, "device-cmyk() color must have at least four components"
          end
          c, m, y, k = cparts[0..3].collect { |s| clamp( parse_num_or_pct(s) ) }
          a = cparts.length==4 ? 1.0 : clamp( parse_num_or_pct(cparts[4]) )
          @ct = :CMYK
          @comp = {:c => c, :m => m, :y => y, :k => k}
          @alpha = a
        end
      else
        raise ArgumentError, "not a valid color #{name.inspect}"
      end
      return nil
    end


    private # --------------------

    # Make sure hue is a number in range [0.360)
    def normalize_hue( hue )
      hue = hue % 360.0
      hue = 0.0 if hue == -0.0
      return hue
    end

    # Insure W + B <= 100%
    def normalize_hwb
      w, b = @comp[:wht], @comp[:blk]
      if w < 0
        w = 0.0
        @comp[:wht] = w
      end
      if b < 0
        b = 0.0
        @comp[:blk] = b
      end
      if w + b > 1.0
        w1 = w / (w+b)
        b1 = b / (w+b)
        @comp[:wht] = w1
        @comp[:blk] = b1
      end
    end

    # Determine RGB equivalent color for HSL and HWB colors
    def recompute_rgb
      case @ct
      when :HSL
        r,g,b = hsl_to_rgb( @comp[:hue], @comp[:sat], @comp[:lite] )
        @comp[:r] = r
        @comp[:g] = g
        @comp[:b] = b
      when :HWB
        r,g,b = hwb_to_rgb( @comp[:hue], @comp[:wht], @comp[:blk] )
        @comp[:r] = r
        @comp[:g] = g
        @comp[:b] = b
      end
    end

    # Converts from HWB to RGB
    def hwb_to_rgb( hue, wht, blk )
      r,g,b = hsl_to_rgb( hue, 1.0, 0.5 )
      f = 1.0 - wht - blk
      r = r * f + wht
      g = g * f + wht
      b = b * f + wht
      [r,g,b]
    end

    # Converts from HSL to RGB
    def hsl_to_rgb( h, s, l )
      if le_zero?(l)
        [0,0,0] # black
      elsif ge_one?(l)
        [1,1,1] # white
      elsif eq_zero?(s)
        [l,l,l] # gray = L
      else
        # Combine lightness and saturation into t1, t2
        t2 = (l <= 0.5) ? (l * (s + 1)) : (l + s - (l*s))
        t1 = l*2 - t2
        r = hue_to_rgb( h+120, t1, t2 )
        g = hue_to_rgb( h, t1, t2 )
        b = hue_to_rgb( h-120, t1, t2 )
        [r, g, b]
      end
    end

    # Utility function used in hsl_to_rgb()
    def hue_to_rgb( hue, t1, t2 )
      sector = normalize_hue(hue) / 60.0
      if sector < 1  # 0..60 degrees
        t1 + ((t2 - t1) * sector)
      elsif sector < 3  # 60..180 degrees
        t2
      elsif sector < 4  # 180..240 degrees
        t1 + (t2 - t1) * (4 - sector);
      else  # 240..360 degres
        t1
      end
    end

    # Parses a CSS hue, used by HSL and HWB color spaces
    def parse_css_hue( hue_name )
      return normalize_hue( hue_name ) if hue_name.is_a? Numeric

      if hue_name =~ /^[+-]?[0-9.]+(deg)?$/
        hue = normalize_hue( hue_name.to_f )
      else
        names = hue_name.split()
        if names.length > 2
          raise ArgumentError, "Hues must contain no more than two name parts: #{hue_name.inspect}"
        end

        h1 = CSS_BASE_HUES[ names[0] ]
        h1pct = 0.5
        if h1.nil? and names.length == 2
          # First name could be a splash hue
          splash_fun = names[0].match( /^([[:alpha:]]+)\((.*)\)$/ )
          if splash_fun
            h1 = splash_fun[1]
            h1pct = clamp( parse_num_or_pct( splash_fun[2] ) )
          else
            h1 = names[0]
            h1pct = 0.25
          end
          h1 = CSS_SPLASH_HUES[ h1 ]
        end

        if names.length == 2
          h2 = CSS_BASE_HUES[ names[1] ]
        else
          h2 = h1
        end

        if h1.nil? || h2.nil?
          raise ArgumentError, "Not a valid hue name: #{hue_name.inspect}"
        end

        if h1 == h2 or h1pct == 0.0
          hue = h2
        elsif h1pct == 1.0
          hue = h1
        else
          if h1 >= h2+180
            h1 -= 360
          elsif h1+180 <= h2
            h1 += 360
          end
          hue = normalize_hue( h1 * h1pct + h2 * (1.0-h1pct) )
        end
      end
      return hue
    end

    # Parses a number or a percentage in CSS format
    def parse_num_or_pct( s, unit=1.0 )
      s.to_f if s.is_a? Numeric

      if s.empty?
        0.0
      elsif s.end_with?('%')
        s[0..-2].to_f / 100.0
      else
        s.to_f / unit
      end
    end

    # Converts a float (0.0 to 1.0) into a percentage string, e.g., "12.34%",
    # truncating excess significant digits.
    def f_to_pct( n )
      sprintf('%.2f', (n * 100.0)).gsub(/\.?0+$/,'') + '%'
    end

  end # end class CSSColor

end
