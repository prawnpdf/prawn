# Vendored in Prawn, without modification.  We are not maintaining this code
# so please contact Austin Ziegler / Keisuke Minami with questions unless your
# problem is directly related to Prawn.
#
#  - Gregory Brown (July 2008) [gregory.t.brown@gmail.com]
#
#---------------------------------------------
# PDF::Writer for Ruby.
#   http://rubyforge.org/projects/ruby-pdf/
#   Copyright 2003 - 2005 Austin Ziegler.
#
#   Licensed under a MIT-style licence. See LICENCE in the main distribution
#   for full licensing information.
#
#   This file is also licensed under standard Ruby licensing provisions: the
#   Ruby licence and the GNU General Public Licence, version 2 or later.
#
# $Id$
#++

# This is based on ImageSize, by Keisuke Minami <keisuke@rccn.com>. It can
# be found at http://www.rubycgi.org/tools/index.en.htm
#
# This has been integrated into PDF::Writer because as yet there has been
# no response to emails asking for my extensions to be integrated and a
# RubyGem package to be made available.

class ImageInfo
  # Image Format Constants
  module Formats
    OTHER     = "OTHER"
    GIF       = "GIF"       # CompuServe GIF87a and GIF89a images.
    PNG       = "PNG"       # Portable Network Graphics, PNG
    JPEG      = "JPEG"      # JPEG
    BMP       = "BMP"       # Windows or OS/2 Bitmaps
    PPM       = "PPM"       # PPM is like PBM, PGM, & XV
    PBM       = "PBM"
    PGM       = "PGM"
    #   XV        = "XV"        # Not supported
    TIFF      = "TIFF"      # TIFF formats
    XBM       = "XBM"       # X Bitmap
    XPM       = "XPM"       # X Pixmap
    PSD       = "PSD"       # PhotoShop
    PCX       = "PCX"       # PCX Bitmap
    SWF       = "SWF"       # Flash
  end
  Type = Formats

  class << self
    def formats
      Formats.constants
    end
    alias :type_list :formats
  end

  JPEG_SOF_BLOCKS = %W(\xc0 \xc1 \xc2 \xc3 \xc5 \xc6 \xc7 \xc9 \xca \xcb \xcd \xce \xcf)
  JPEG_APP_BLOCKS = %W(\xe0 \xe1 \xe2 \xe3 \xe4 \xe5 \xe6 \xe7 \xe8 \xe9 \xea \xeb \xec \xed \xee \xef)

  # Receive image & make size. argument is image String or IO
  def initialize(data, format = nil)
    @data   = data.dup rescue data
    @info   = {}

    if @data.kind_of?(IO)
      @top = @data.read(128)
      @data.seek(0, 0)
      # Define Singleton-method definition to IO (byte, offset)
      def @data.read_o(length = 1, offset = nil)
        self.seek(offset, 0) if offset
        ret = self.read(length)
        raise "cannot read!!" unless ret
        ret
      end
    elsif @data.is_a?(String)
      @top = @data[0, 128]
      # Define Singleton-method definition to String (byte, offset)
      @data.extend(Prawn::Images::OffsetReader)
    else
      raise "argument class error!! #{data.type}"
    end

    if format.nil?
      @format = discover_format
    else
      match = false
      Formats.constants.each { |t| match = true if format == t }
      raise("format is failed. #{format}\n") unless match
      @format = format
    end

    __send__("measure_#@format".intern) unless @format == Formats::OTHER

    @data = data.dup
  end

  attr_reader :format
  alias :get_type :format
  attr_reader :height
  alias :get_height :height
  attr_reader :width
  alias :get_width width

  attr_reader :bits
  attr_reader :channels

  attr_reader :info

  def discover_format
    if    @top        =~ %r{^GIF8[79]a}
      Formats::GIF
    elsif @top[0, 3]  == "\xff\xd8\xff"
      Formats::JPEG
    elsif @top[0, 8]  == "\x89PNG\x0d\x0a\x1a\x0a"
      Formats::PNG
    elsif @top[0, 3]  == "FWS"
      Formats::SWF
    elsif @top[0, 4]  == "8BPS"
      Formats::PSD
    elsif @top[0, 2]  == 'BM'
      Formats::BMP
    elsif @top[0, 4]  == "MM\x00\x2a"
      Formats::TIFF
    elsif @top[0, 4]  == "II\x2a\x00"
      Formats::TIFF
    elsif @top[0, 12] == "\x00\x00\x00\x0c\x6a\x50\x20\x20\x0d\x0a\x87\x0a"
      Formats::JP2
    elsif @top        =~ %r{^P[1-7]}
      Formats::PPM
    elsif @top        =~ %r{\#define\s+\S+\s+\d+}
      Formats::XBM
    elsif @top        =~ %r{/\* XPM \*/}
      Formats::XPM
    elsif @top[0] == 10
      Formats::PCX
    else
      Formats::OTHER  # might be WBMP
    end
  end
  private :discover_format

  def measure_GIF
    @data.read_o(6) # Skip GIF8.a
    @width, @height, @bits = @data.read_o(5).unpack('vvC')
    if @bits & 0x80 == 0x80
      @bits = (@bits & 0x07) + 1
    else
      @bits = 0
    end
    @channels = 3
  end
  private :measure_GIF

  def measure_PNG
    @data.read_o(12)
    raise "This file is not PNG." unless @data.read_o(4) == "IHDR"
    # The file information is in the IHDR section.
    #   Offset  Bytes Meaning
    #    0      4     Width
    #    5      4     Height
    #    9      1     Bit Depth
    #   10      1     Compression Method
    #   11      1     Filter Method
    #   12      1     Interlace Method
    ihdr = @data.read_o(13).unpack("NNCCCCC")
    @width                      = ihdr[0]
    @height                     = ihdr[1]
    @bits                       = ihdr[2]
    @info[:color_type]          = ihdr[3]
    @info[:compression_method]  = ihdr[4]
    @info[:filter_method]       = ihdr[5]
    @info[:interlace_method]    = ihdr[6]


  end
  private :measure_PNG

  def measure_JPEG
    c_marker = "\xff" # Section marker.
    @data.read_o(2)   # Skip the first two bytes of JPEG identifier.
    loop do
      marker, code, length = @data.read_o(4).unpack('aan')
      raise "JPEG marker not found!" if marker != c_marker

      if JPEG_SOF_BLOCKS.include?(code)
        @bits, @height, @width, @channels = @data.read_o(6).unpack("CnnC")
        break
      end

      buffer = @data.read_o(length - 2)

      if JPEG_APP_BLOCKS.include?(code)
        @info["APP#{code.to_i - 0xe0}"] = buffer
      end
    end
  end
  private :measure_JPEG

  def measure_BMP
    # Skip the first 14 bytes of the image.
    @data.read_o(14)
    # Up to the next 16 bytes will be used.
    dim = @data.read_o(16)

    # Get the "size" of the image from the next four bytes.
    size = dim.unpack("V").first # <- UNPACK RETURNS ARRAY, SO GET FIRST ELEMENT

    if size == 12
      @width, @height, @bits = dim.unpack("x4vvx3C")
    elsif size > 12 and (size <= 64 or size == 108)
      @width, @height, @bits = dim.unpack("x4VVv")
    end  
  end
  private :measure_BMP

  def measure_PPM
    header = @data.read_o(1024)
    header.gsub!(/^\#[^\n\r]*/m, "")
      md = %r{^(P[1-6])\s+?(\d+)\s+?(\d+)}mo.match(header)

    @width  = md.captures[1]
    @height = md.captures[2]

    case md.captures[0]
    when "P1", "P4"
      @format = "PBM"
    when "P2", "P5"
      @format = "PGM"
    when "P3", "P6"
      @format = "PPM"
      #   when "P7"
      #     @format = "XV"
      #     header =~ /IMGINFO:(\d+)x(\d+)/m
      #     width = $1.to_i; height = $2.to_i
    end
  end
  private :measure_PPM

  alias :measure_PGM :measure_PPM
  private :measure_PGM
  alias :measure_PBM :measure_PPM
  private :measure_PBM

  XBM_DIMENSIONS_RE = %r{^\#define\s*\S*\s*(\d+)\s*\n\#define\s*\S*\s*(\d+)}mi
    def measure_XBM
      md = XBM_DIMENSIONS_RE.match(@data.read_o(1024))

      @width  = md.captures[0].to_i
      @height = md.captures[1].to_i
    end
  private :measure_XBM

  XPM_DIMENSIONS_RE = %r<"\s*(\d+)\s+(\d+)(\s+\d+\s+\d+){1,2}\s*">m
  def measure_XPM
    while line = @data.read_o(1024)
      md = XPM_DIMENSIONS_RE.match(line)
      if md
        @width  = md.captures[0].to_i
        @height = md.captures[1].to_i
        break
      end
    end
  end
  private :measure_XPM

  def measure_PSD
    @width, @height = @data.read_o(26).unpack("x14NN")
  end
  private :measure_PSD

  def measure_PCX
    header = @data.read_o(128)
    head_part = header.unpack('C4S4')
    @width  = head_part[6] - head_part[4] + 1
    @height = head_part[7] - head_part[5] + 1
  end
  private :measure_PCX

  def measure_SWF
    header = @data.read_o(9)
    raise "This file is not SWF."  unless header.unpack('a3')[0] == 'FWS'

    bits    = Integer("0b#{header.unpack('@8B5')}")
    header << @data.read_o(bits * 4 / 8 + 1)

    str     = *(header.unpack("@8B#{5 + bits * 4}"))
    last    = 5
    x_min   = Integer("0b#{str[last, bits]}")
    x_max   = Integer("0b#{str[(last + bits), bits]}")
    y_min   = Integer("0b#{str[(last + (2 * bits)), bits]}")
    y_max   = Integer("0b#{str[(last + (3 * bits)), bits]}")
    @width  = (x_max - x_min) / 20
    @height = (y_max - y_min) / 20
  end
  private :measure_SWF

  # The same as SWF, except that the original data is compressed with
  # Zlib. Disabled for now.
  def measure_SWC
  end
  private :measure_SWC

  def measure_TIFF
    # 'v' little-endian
    # 'n' default to big-endian
    endian = (@data.read_o(4) =~ /II\x2a\x00/o) ? 'v' : 'n'

    packspec = [
      nil,           # nothing (shouldn't happen)
  'C',           # BYTE (8-bit unsigned integer)
  nil,           # ASCII
  endian,        # SHORT (16-bit unsigned integer)
  endian.upcase, # LONG (32-bit unsigned integer)
  nil,           # RATIONAL
  'c',           # SBYTE (8-bit signed integer)
  nil,           # UNDEFINED
  endian,        # SSHORT (16-bit unsigned integer)
  endian.upcase, # SLONG (32-bit unsigned integer)
    ]

    # Find the IFD location.
    ifd_addr    = *(@data.read_o(4).unpack(endian.upcase))
    # Get the number of entries in the IFD.
    ifd         = @data.read_o(2, ifd_addr)
    num_dirent  = *(ifd.unpack(endian))         # Make it useful
    ifd_addr    += 2
    num_dirent  = ifd_addr + (num_dirent * 12)  # Calc. maximum offset of IFD

    loop do
      break if @width and @height

      ifd = @data.read_o(12, ifd_addr)  # Get directory entry.
      break if ifd.nil? or ifd_addr > num_dirent
      ifd_addr += 12

      tag   = *(ifd.unpack(endian))       # ...decode its tag
      type  = *(ifd[2, 2].unpack(endian)) # ... and data type

      # Check the type for sanity.
      next if type > packspec.size or packspec[type].nil?

      case tag
      when 0x0100, 0xa002 # width
        @width  = *(ifd[8, 4].unpack(packspec[type]))
      when 0x0101, 0xa003 # height
        @height = *(ifd[8, 4].unpack(packspec[type]))
      end
    end
  end
  private :measure_TIFF
end      
