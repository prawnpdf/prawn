# encoding: utf-8

# metrics.rb : Font metrics parsers for AFM and TTF.
#
# Font::Metrics::Adobe is mainly a port of CPAN's Font::AFM 
# http://search.cpan.org/~gaas/Font-AFM-1.19/AFM.pm
#
# Copyright May 2008, Gregory Brown / James Edward Gray II. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Font #:nodoc:
    class Metrics #:nodoc:

      include Prawn::Font::Wrapping

      def self.[](font)
        data[font] ||= case(font)
          when /\.ttf$/
            TTF.new(font)
          else
            Adobe.new(font)
        end
      end 

      def self.data
        @data ||= {}
      end   

      def string_height(string,options={})
        string = naive_wrap(string, options[:line_width], options[:font_size])
        string.lines.to_a.length * font_height(options[:font_size])
      end

      class Adobe < Metrics #:nodoc:     
         
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
                                  
        def initialize(font_name)            
          @attributes     = {}   
          @glyph_widths   = {}
          @bounding_boxes = {}
          @kern_pairs     = {}
          
          file = font_name.sub(/\.afm$/,'') + '.afm'
          unless file[0..0] == "/"
             file = find_font(file)
          end    
                           
          parse_afm(file)
        end
        
        def bbox
          fontbbox.split(/\s+/).map { |e| Integer(e) }
        end   

        def font_height(font_size)
          Float(bbox[3] - bbox[1]) * font_size / 1000.0
        end        
      
        # calculates the width of the supplied string.
        # String *must* be encoded as iso-8859-1
        def string_width(string, font_size, options = {})   
          scale = font_size / 1000.0
          
          if options[:kerning]
            kern(string).inject(0) do |s,r|   
              if r.is_a? String
                s + string_width(r, font_size, :kerning => false)
              else 
                s - (r * scale)
              end
            end
          else
            string.unpack("C*").inject(0) do |s,r|
              s + latin_glyphs_table[r]
            end * scale
          end
        end
        
        # converts a string into an array with spacing offsets
        # bewteen characters that need to be kerned
        #
        # String *must* be encoded as iso-8859-1
        def kern(string) 
          kerned = string.unpack("C*").inject([]) do |a,r|
            if a.last.is_a? Array
              if kern = latin_kern_pairs_table[[a.last.last, r]]
                a << kern << [r]
              else
                a.last << r
              end
            else
              a << [r]
            end
            a
          end            
          
          kerned.map { |r| 
            i = r.is_a?(Array) ? r.pack("C*") : r 
            i.force_encoding("ISO-8859-1") if i.respond_to?(:force_encoding)
            i.is_a?(Numeric) ? -i : i
          }                        
        end
        
        def latin_kern_pairs_table
          @kern_pairs_table ||= @kern_pairs.inject({}) do |h,p|
            h[p[0].map { |n| ISOLatin1Encoding.index(n) }] = p[1]
            h
          end
        end
 
        def latin_glyphs_table
          @glyphs_table ||= (0..255).map do |i|
            @glyph_widths[ISOLatin1Encoding[i]].to_i
          end 
        end

        def ascender
          @attributes["ascender"].to_i
        end

        def descender
          @attributes["descender"].to_i 
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
      
        def metrics_path
          if m = ENV['METRICS']
            @metrics_path ||= m.split(':')
          else 
            @metrics_path ||= [
              "/usr/lib/afm",
              "/usr/local/lib/afm",
              "/usr/openwin/lib/fonts/afm/", 
               Prawn::BASEDIR+'/data/fonts/','.'] 
          end
        end 

        def has_kerning_data?
          true
        end

        def type0?
          false
        end

        # perform any changes to the string that need to happen
        # before it is rendered to the canvas
        #
        # String *must* be encoded as iso-8859-1
        def convert_text(text, options={})
          options[:kerning] ? kern(text) : text
        end

        private
      
        def find_font(file)
          metrics_path.find { |f| File.exist? "#{f}/#{file}" } + "/#{file}"    
        rescue NoMethodError
          raise Prawn::Errors::UnknownFont, 
            "Couldn't find the font: #{file} in any of:\n" + 
             @metrics_path.join("\n")
        end  
      
        def parse_afm(file) 
          section = []
          
          File.open(file,"rb") do |file|
            
            file.each do |line| 
              if line =~ /^Start(\w+)/
                section.push $1
                next
              elsif line =~ /^End(\w+)/
                section.pop
                next
              end
              
              if section == ["FontMetrics", "CharMetrics"]
                next unless line =~ /^CH?\s/  
          
                name                  = line[/\bN\s+(\.?\w+)\s*;/, 1]
                @glyph_widths[name]   = line[/\bWX\s+(\d+)\s*;/, 1].to_i
                @bounding_boxes[name] = line[/\bB\s+([^;]+);/, 1].to_s.rstrip
              elsif section == ["FontMetrics", "KernData", "KernPairs"]
                next unless line =~ /^KPX\s+(\.?\w+)\s+(\.?\w+)\s+(-?\d+)/
                @kern_pairs[[$1, $2]] = $3.to_i
              elsif section == ["FontMetrics", "KernData", "TrackKern"]
                next
              elsif section == ["FontMetrics", "Composites"]
                next
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

      class TTF < Metrics #:nodoc:
        
        def initialize(font)
          @ttf = ::Font::TTF::File.open(font,"rb")
          @attributes     = {}
          @glyph_widths   = {}
          @bounding_boxes = {}
        end

        def cmap
          @cmap ||= enc_table.charmaps
        end

        def string_width(string, font_size, options = {})
          scale = font_size / 1000.0
          if options[:kerning]
            kern(string,:skip_conversion => true).inject(0) do |s,r|
              if r.is_a? String  
                s + string_width(r, font_size, :kerning => false)
              else 
                s + r * scale
              end
            end
          else
            string.unpack("U*").inject(0) do |s,r|
              s + character_width_by_code(r)
            end * scale
          end
        end   
        
        # TODO: NASTY. 
        def kern(string,options={})   
          string.unpack("U*").inject([]) do |a,r|
            if a.last.is_a? Array
              if kern = kern_pairs_table[[cmap[a.last.last], cmap[r]]] 
                kern *= scale_factor
                a << kern << [r]
              else
                a.last << r
              end
            else
              a << [r]
            end
            a
          end.map { |r| 
            if options[:skip_conversion]
              r.is_a?(Array) ? r.pack("U*") : r
            else
              i = r.is_a?(Array) ? r.pack("U*") : r 
              x = if i.is_a?(String)
                unicode_codepoints = i.unpack("U*")
                glyph_codes = unicode_codepoints.map { |u| 
                  enc_table.get_glyph_id_for_unicode(u)
                }
                glyph_codes.pack("n*")
              else
                i
              end
              x.is_a?(Numeric) ? -x : x 
            end
          }
        end

        def glyph_widths
          glyphs = cmap.values.uniq.sort
          first_glyph = glyphs.shift
          widths = [first_glyph, [Integer(hmtx[first_glyph][0] * scale_factor)]]
          prev_glyph = first_glyph
          glyphs.each do |glyph|
            unless glyph == prev_glyph + 1
              widths << glyph
              widths << []
            end
            widths.last << Integer(hmtx[glyph][0] * scale_factor )
            prev_glyph = glyph
          end
          widths
        end

        def bbox
          head = @ttf.get_table(:head)
          [:x_min, :y_min, :x_max, :y_max].map do |atr| 
            Integer(head.send(atr)) * scale_factor
          end
        end

        def ascender
          Integer(@ttf.get_table(:hhea).ascender * scale_factor)
        end

        def descender
          Integer(@ttf.get_table(:hhea).descender * scale_factor)
        end

        def font_height(size)
          (ascender - descender) * size / 1000.0
        end

        def basename
          return @basename if @basename
          ps_name = ::Font::TTF::Table::Name::NameRecord::POSTSCRIPT_NAME

          @ttf.get_table(:name).name_records.each do |rec|
            @basename = rec.utf8_str.to_sym if rec.name_id == ps_name            
          end
          @basename
        end

        def enc_table
          @enc_table ||= @ttf.get_table(:cmap).encoding_tables.find do |t|
            t.class == ::Font::TTF::Table::Cmap::EncodingTable4
          end
        end

        # TODO: instead of creating a map that contains every glyph in the font,
        #       only include the glyphs that were used
        def to_unicode_cmap
          return @to_unicode if @to_unicode
          @to_unicode = Prawn::Font::CMap.new
          unicode_for_glyph = cmap.invert
          glyphs = unicode_for_glyph.keys.uniq.sort
          glyphs.each do |glyph|
            @to_unicode[unicode_for_glyph[glyph]] = glyph
          end
          @to_unicode
        end
        
        def kern_pairs_table
          return @kern_pairs_table if @kern_pairs_table
          
          table = @ttf.get_table(:kern).subtables.find { |s| 
            s.is_a? ::Font::TTF::Table::Kern::KerningSubtable0 }
          
          if table
            @kern_pairs_table ||= table.kerning_pairs.inject({}) do |h,p|
              h[[p.left, p.right]] = p.value
              h
            end
          else
            @kern_pairs_table = {}
          end
        end

        def has_kerning_data?
          !kern_pairs_table.empty? 
        rescue ::Font::TTF::TableMissing
          false
        end

        def type0?
          true
        end

        def convert_text(text,options)
          text = text.chomp
          if options[:kerning]
            kern(text)
          else
           unicode_codepoints = text.unpack("U*")
            glyph_codes = unicode_codepoints.map { |u| 
              enc_table.get_glyph_id_for_unicode(u)
            }
            text = glyph_codes.pack("n*")
          end
        end

        private

        def hmtx
          @hmtx ||= @ttf.get_table(:hmtx).metrics
        end

        def character_width_by_code(code)
          return 0 unless cmap[code]
          Integer(hmtx[cmap[code]][0] * scale_factor)           
        end                   

        def scale_factor
          @scale ||= 1 / Float(@ttf.get_table(:head).units_per_em / 1000.0)
        end

      end
    end
  end   
end
