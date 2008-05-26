# afm.rb : Implementation of a simple Adobe Font Metrics parser
#
# Mainly a port of CPAN's Font::AFM 
# http://search.cpan.org/~gaas/Font-AFM-1.19/AFM.pm
#
# Copyright May 2008, Gregory Brown / James Edward Gray II. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Font
    class AFM #:nodoc:
    
      ISOLatin1Encoding = %w[
       .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
       .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
       .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
       .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef space
       exclam quotedbl numbersign dollar percent ampersand quoteright
       parenleft parenright asterisk plus comma minus period slash zero one
       two three four five six seven eight nine colon semicolon less equal
       greater question at A B C D E F G H I J K L M N O P Q R S
       T U V W X Y Z bracketleft backslash bracketright asciicircum
       underscore quoteleft a b c d e f g h i j k l m n o p q r s
       t u v w x y z braceleft bar braceright asciitilde .notdef .notdef
       .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
       .notdef .notdef .notdef .notdef .notdef .notdef .notdef dotlessi grave
       acute circumflex tilde macron breve dotaccent dieresis .notdef ring
       cedilla .notdef hungarumlaut ogonek caron space exclamdown cent
       sterling currency yen brokenbar section dieresis copyright ordfeminine
       guillemotleft logicalnot hyphen registered macron degree plusminus
       twosuperior threesuperior acute mu paragraph periodcentered cedilla
       onesuperior ordmasculine guillemotright onequarter onehalf threequarters
       questiondown Agrave Aacute Acircumflex Atilde Adieresis Aring AE
       Ccedilla Egrave Eacute Ecircumflex Edieresis Igrave Iacute Icircumflex
       Idieresis Eth Ntilde Ograve Oacute Ocircumflex Otilde Odieresis
       multiply Oslash Ugrave Uacute Ucircumflex Udieresis Yacute Thorn
       germandbls agrave aacute acircumflex atilde adieresis aring ae
       ccedilla egrave eacute ecircumflex edieresis igrave iacute icircumflex
       idieresis eth ntilde ograve oacute ocircumflex otilde odieresis divide
       oslash ugrave uacute ucircumflex udieresis yacute thorn ydieresis
      ]    
    
      attr_reader :attributes
             
      def self.data
        @data ||= {}
      end   
         
      def self.[](font)
        data[font] ||= new(font) 
      end 
        
      def initialize(font_name)            
        @attributes     = {}   
        @glyph_widths   = {}
        @bounding_boxes = {}  
        
        file = font_name + (font_name =~ /\.afm$/ ? '' : '.afm')   
        unless file[0..0] == "/"
           file = find_font(file)
        end    
                         
        parse_afm(file)
      end   
    
      def string_width(string,font_size)   
        scale = font_size / 1000.0
        string.unpack("C*").
               inject(0) { |s,r| s + latin_glyphs_table[r] } * scale
      end

      # Hackish, but does the trick for now.
      def method_missing(method, *args, &block)
        name = method.to_s.delete("_")
        if @attributes.include? name
          @attributes[name]
        else
          super  
        end
      end
    
      private
    
      def metrics_path
        @metrics_path ||= (ENV['METRICS'] || 
          "/usr/lib/afm:/usr/local/lib/afm:"+
          "/usr/openwin/lib/fonts/afm/:"+
          "#{Prawn::BASEDIR+'/data/fonts/'}:.").split(':')
      end 
    
      def find_font(file)
        metrics_path.find { |f| File.exist? "#{f}/#{file}" } + "/#{file}"    
      rescue NoMethodError
        raise "Couldn't find the font: #{file} in any of:\n" +
              @metrics_path.join("\n")
      end  
    
      def latin_glyphs_table
        @glyphs_table ||= (0..255).map do |i|
          @glyph_widths[ISOLatin1Encoding[i]].to_i
        end 
      end
    
      def parse_afm(file) 
        section = nil  
        File.open(file,"rb") do |file|
          file.each do |line| 
            if line =~ /^Start(\w+)/
              section = $1
            elsif line =~ /^End(\w+)/
              section = nil
              if $1 == "FontMetrics"
                break
              else
                next
              end
            end
            next if %w[KernData Composites].include? section
        
            if section == "CharMetrics"
              next unless line =~ /^CH?\s/  
        
              name                  = line[/\bN\s+(\.?\w+)\s*;/, 1]
              @glyph_widths[name]   = line[/\bWX\s+(\d+)\s*;/, 1].to_i
              @bounding_boxes[name] = line[/\bB\s+([^;]+);/, 1].to_s.rstrip
            elsif line =~ /(^\w+)\s+(.*)/
              key, value = $1.to_s.downcase, $2      
            
              @attributes[key] =  @attributes[key] ? 
                Array(@attributes[key]) << value : value
            else
              warn "Can't parse:  #{line}"
            end
          end
        end
      end               
    end
  end   
end
