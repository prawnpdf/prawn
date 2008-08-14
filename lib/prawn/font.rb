# encoding: utf-8

require "prawn/font/wrapping"       
require "prawn/font/metrics"
require "prawn/font/cmap" 

module Prawn 
  
  class Document 
    # Sets the current font.
    #
    # The single parameter must be a string. It can be one of the 14 built-in
    # fonts supported by PDF, or the location of a TTF file. The BUILT_INS
    # array specifies the valid built in font values.
    #
    #   pdf.font "Times-Roman"
    #   pdf.font "Chalkboard.ttf"
    #
    # If a ttf font is specified, the full file will be embedded in the 
    # rendered PDF. This should be your preferred option in most cases. 
    # It will increase the size of the resulting file, but also make it 
    # more portable.
    #
    def font(name=nil) 
      if name  
        Prawn::Font.register(name,:for => self) unless font_registry[name]
        @font_name = name   
      elsif @font_name.nil?                                              
        Prawn::Font.register("Helvetica", :for => self) 
        @font_name = "Helvetica"             
      end  
      font_registry[@font_name] 
    end   
    
    def font_registry
      @font_registry ||= {}
    end
  end

  class Font
    
    BUILT_INS = %w[ Courier Helvetica Times-Roman Symbol ZapfDingbats 
                    Courier-Bold Courier-Oblique Courier-BoldOblique
                    Times-Bold Times-Oblique Times-BoldOblique
                    Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique ] 
                        
    DEFAULT_SIZE = 12
      
    def self.register(name,options={})         
       options[:for].font_registry[name] = Font.new(name,options)
    end  
      
    attr_reader   :metrics, :identifier, :reference, :name
    attr_writer   :size         
      
    def initialize(name,options={}) 
      @name       = name           
      @metrics    = Prawn::Font::Metrics[name] 
      @document   = options[:for]        
      
      @document.proc_set :PDF, :Text  
      @size       = DEFAULT_SIZE
      @identifier = :"F#{@document.font_registry.size + 1}"  
      
      case(name)
      when /\.ttf$/
        embed_ttf(name)
      else
        register_builtin(name)
      end  
      
      add_to_current_page    
    end 
      
    def size(points=nil)      
      return @size unless points
      size_before_yield = @size
      @size = points
      yield
      @size = size_before_yield
    end    
    
    def width_of(string)
      @metrics.string_width(string,@size)
    end     
    
    def height_of(string,options={})
      @metrics.string_height( string, :font_size  => @size, 
                                      :line_width => options[:line_width] ) 
    end                     
    
    def height
      @metrics.font_height(@size)       
    end  
    
    def normalize_encoding(text)
      # check the string is encoded sanely
      # - UTF-8 for TTF fonts
      # - ISO-8859-1 for Built-In fonts
      if @metrics.type0?
        normalize_ttf_encoding(text) 
      else
        normalize_builtin_encoding(text) 
      end 
    end
    
    def add_to_current_page
      @document.page_fonts.merge!(@identifier => @reference)
    end              
    
    private
    
    # built-in fonts only work with latin encoding, so translate the string
    def normalize_builtin_encoding(text)
      if text.respond_to?(:encode!)
        text.encode!("ISO-8859-1")
      else
        require 'iconv'
        text.replace Iconv.conv('ISO-8859-1', 'utf-8', text)
      end
    rescue
      raise Prawn::Errors::IncompatibleStringEncoding, "When using a " +
          "builtin font, only characters that exist in " +
          "WinAnsi/ISO-8859-1 are allowed."
    end

    def normalize_ttf_encoding(text)
      # TODO: if the current font is a built in one, we can't use the utf-8
      # string provided by the user. We should convert it to WinAnsi or
      # MacRoman or some such.
      if text.respond_to?(:encode!)
        # if we're running under a M17n aware VM, ensure the string provided is
        # UTF-8 (by converting it if necessary)
        begin
          text.encode!("UTF-8")
        rescue
          raise Prawn::Errors::IncompatibleStringEncoding, "Encoding " +
          "#{text.encoding} can not be transparently converted to UTF-8. " +
          "Please ensure the encoding of the string you are attempting " +
          "to use is set correctly"
        end
      else
        # on a non M17N aware VM, use unpack as a hackish way to verify the
        # string is valid utf-8. I thought it was better than loading iconv
        # though.
        begin
          text.unpack("U*")
        rescue
          raise Prawn::Errors::IncompatibleStringEncoding, "The string you " +
          "are attempting to render is not encoded in valid UTF-8."
        end
      end
    end
    
    def register_builtin(name) 
      unless BUILT_INS.include?(name)
        raise Prawn::Errors::UnknownFont, "#{name} is not a known font."
      end      
      
      @reference = @document.ref( :Type     => :Font,
                                  :Subtype  => :Type1,
                                  :BaseFont => name.to_sym,
                                  :Encoding => :WinAnsiEncoding)                                                   
    end    
    
    def embed_ttf(file)
      unless File.file?(file)
        raise ArgumentError, "file #{file} does not exist"
      end

      basename = @metrics.basename

      raise "Can't detect a postscript name for #{file}" if basename.nil?

      @encodings = @metrics.enc_table

      if @encodings.nil?
        raise "#{file} missing the required encoding table"
      end

      font_content = File.open(file,"rb") { |f| f.read }
      compressed_font = Zlib::Deflate.deflate(font_content)

      fontfile = @document.ref(:Length => compressed_font.size,
                               :Length1 => font_content.size,
                               :Filter => :FlateDecode )
      fontfile << compressed_font

      # TODO: Not sure what to do about CapHeight, as ttf2afm doesn't
      # pick it up. Missing proper StemV and flags
      #
      descriptor = @document.ref(:Type        => :FontDescriptor,
                                 :FontName    => basename,
                                 :FontFile2   => fontfile,
                                 :FontBBox    => @metrics.bbox,
                                 :Flags       => 32, # FIXME: additional flags
                                 :StemV       => 0,
                                 :ItalicAngle => 0,
                                 :Ascent      => @metrics.ascender,
                                 :Descent     => @metrics.descender )    

      descendant = @document.ref(:Type           => :Font,
                                 :Subtype        => :CIDFontType2, # CID, TTF
                                 :BaseFont       => basename,
                                 :CIDSystemInfo  => { :Registry   => "Adobe",
                                                      :Ordering   => "Identity",
                                                      :Supplement => 0 },
                                 :FontDescriptor => descriptor,
                                 :W              => @metrics.glyph_widths,
                                 :CIDToGIDMap    => :Identity ) 

      to_unicode_content = @metrics.to_unicode_cmap.to_s
      compressed_to_unicode = Zlib::Deflate.deflate(to_unicode_content)   
      
      to_unicode = @document.ref(:Length  => compressed_to_unicode.size,
                                 :Length1 => to_unicode_content.size,
                                 :Filter  => :FlateDecode )
      to_unicode << compressed_to_unicode

      @reference = @document.ref(:Type            => :Font,
                                 :Subtype         => :Type0,
                                 :BaseFont        => basename,
                                 :DescendantFonts => [descendant],
                                 :Encoding        => :"Identity-H",
                                 :ToUnicode       => to_unicode)

    end                              

  end
   
end
