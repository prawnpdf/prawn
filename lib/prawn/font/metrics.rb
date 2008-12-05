# encoding: utf-8

# metrics.rb : Font metrics parsers for AFM and TTF.
#
# Font::Metrics::Adobe is mainly a port of CPAN's Font::AFM 
# http://search.cpan.org/~gaas/Font-AFM-1.19/AFM.pm
#
# Copyright May 2008, Gregory Brown / James Edward Gray II. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'prawn/encoding'

module Prawn
  class Font 
    class Metrics #:nodoc:

      include Prawn::Font::Wrapping

      def self.[](font)
        data[font] ||= (font.match(/\.ttf$/i) ? TTF : Adobe).new(font)
      end 

      def self.data
        @data ||= {}
      end   

      def string_height(string,options={}) 
        string = naive_wrap(string, options[:line_width], options[:font_size])
        string.lines.to_a.length * font_height(options[:font_size])
      end   
      
      def font_height(size)
        (ascender - descender + line_gap) * size / 1000.0
      end

      class Adobe < Metrics #:nodoc:     
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
              if k = latin_kern_pairs_table[[a.last.last, r]]
                a << k << [r]
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
            h[p[0].map { |n| Encoding::WinAnsi::CHARACTERS.index(n) }] = p[1]
            h
          end
        end
 
        def latin_glyphs_table
          @glyphs_table ||= (0..255).map do |i|
            @glyph_widths[Encoding::WinAnsi::CHARACTERS[i]].to_i
          end 
        end

        def ascender
          @attributes["ascender"].to_i
        end

        def descender
          @attributes["descender"].to_i 
        end  
        
        def line_gap    
          Float(bbox[3] - bbox[1]) - (ascender - descender)
        end

        # Hackish, but does the trick for now.
        def method_missing(method, *args, &block)
          name = method.to_s.delete("_")
          @attributes.include?(name) ? @attributes[name] : super
        end  
      
        def metrics_path
          if m = ENV['METRICS']
            @metrics_path ||= m.split(':')
          else 
            @metrics_path ||= [
              ".", "/usr/lib/afm",
              "/usr/local/lib/afm",
              "/usr/openwin/lib/fonts/afm/", 
               Prawn::BASEDIR+'/data/fonts/'] 
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
        #
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
      
        def parse_afm(file_name) 
          section = []

          File.foreach(file_name) do |line|        
            case line
            when /^Start(\w+)/
              section.push $1
              next
            when /^End(\w+)/
              section.pop
              next
            end

            case section
            when ["FontMetrics", "CharMetrics"]
              next unless line =~ /^CH?\s/  

              name                  = line[/\bN\s+(\.?\w+)\s*;/, 1]
              @glyph_widths[name]   = line[/\bWX\s+(\d+)\s*;/, 1].to_i
              @bounding_boxes[name] = line[/\bB\s+([^;]+);/, 1].to_s.rstrip
            when ["FontMetrics", "KernData", "KernPairs"]
              next unless line =~ /^KPX\s+(\.?\w+)\s+(\.?\w+)\s+(-?\d+)/
              @kern_pairs[[$1, $2]] = $3.to_i
            when ["FontMetrics", "KernData", "TrackKern"], 
              ["FontMetrics", "Composites"]
              next
            else
              parse_generic_afm_attribute(line)
            end
          end 
        end

        def parse_generic_afm_attribute(line)
          line =~ /(^\w+)\s+(.*)/
          key, value = $1.to_s.downcase, $2      

          @attributes[key] =  @attributes[key] ? 
          Array(@attributes[key]) << value : value
        end     
      end

      class TTF < Metrics #:nodoc:  
        
        attr_accessor :ttf
        
        def initialize(font)
          @ttf = TTFunk::File.new(font)
          @attributes       = {}
          @glyph_widths     = {}
          @bounding_boxes   = {} 
          @char_widths      = {}   
          @has_kerning_data = !! @ttf.kern? && @ttf.kern.sub_tables[0]
        end

        def cmap
          @cmap ||= @ttf.cmap.formats[4]
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
          a = []
          
          string.unpack("U*").each do |r|
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
          end
          
          a.map { |r| 
            if options[:skip_conversion]
              r.is_a?(Array) ? r.pack("U*") : r
            else
              i = r.is_a?(Array) ? r.pack("U*") : r 
              x = if i.is_a?(String)
                unicode_codepoints = i.unpack("U*")
                glyph_codes = unicode_codepoints.map { |u| cmap[u] }
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
          [:x_min, :y_min, :x_max, :y_max].map do |atr| 
            Integer(@ttf.head.send(atr)) * scale_factor
          end
        end

        def ascender
          Integer(@ttf.hhea.ascent * scale_factor)
        end

        def descender
          Integer(@ttf.hhea.descent * scale_factor)
        end      
        
        def line_gap
          Integer(@ttf.hhea.line_gap * scale_factor)   
        end

        def basename
          @basename ||= @ttf.name.postscript_name
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
          @kerning_data ||= has_kerning_data? ? @ttf.kern.sub_tables[0] : {}
        end

        def has_kerning_data?
          @has_kerning_data 
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
            glyph_codes = unicode_codepoints.map { |u| cmap[u] }
            text = glyph_codes.pack("n*")
          end
        end
        
        private

        def hmtx
          @hmtx ||= @ttf.hmtx.values
        end         
        
        def character_width_by_code(code)    
          return 0 unless cmap[code]
          @char_widths[code] ||= Integer(hmtx[cmap[code]][0] * scale_factor)           
        end                   

        def scale_factor
          @scale ||= 1000 * Float(@ttf.head.units_per_em)**-1
        end

      end
    end
  end   
end
