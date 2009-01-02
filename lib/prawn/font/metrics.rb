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
require 'ttfunk/subset_collection'

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
        #
        # String *must* be encoded as WinAnsi 
        #
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
        # String *must* be encoded as WinAnsi
        #
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
            i.force_encoding("Windows-1252") if i.respond_to?(:force_encoding)
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

        # Perform any changes to the string that need to happen
        # before it is rendered to the canvas. Returns an array of
        # subset "chunks", where each chunk is an array of two elements.
        # The first element is the font subset number, and the second
        # is either a string or an array (for kerned text).
        #
        # For Adobe fonts, there is only ever a single subset, so
        # the first element of the array is "0", and the second is
        # the string itself (or an array, if kerning is performed).
        #
        # The +text+ parameter must be in WinAnsi encoding (cp1252).
        def encode_text(text, options={})
          [[0, options[:kerning] ? kern(text) : text]]
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

        attr_reader :ttf, :subsets
        
        def initialize(font)
          @ttf              = TTFunk::File.open(font)
          @subsets          = TTFunk::SubsetCollection.new(@ttf)
          @attributes       = {}
          @bounding_boxes   = {} 
          @char_widths      = {}   
          @has_kerning_data = !! @ttf.kerning.exists? && @ttf.kerning.tables.any?
        end

        def cmap
          @cmap ||= @ttf.cmap.unicode.first or raise("no unicode cmap for font")
        end
        
        # +string+ must be UTF8-encoded.
        def string_width(string, font_size, options = {})
          scale = font_size / 1000.0
          if options[:kerning]
            kern(string).inject(0) do |s,r|
              if r.is_a?(Numeric)
                s + r * scale
              else 
                r.inject(s) { |s, u| s + character_width_by_code(u) } * scale
              end
            end
          else
            string.unpack("U*").inject(0) do |s,r|
              s + character_width_by_code(r)
            end * scale
          end
        end   
        
        # +string+ must be UTF8-encoded.
        #
        # Returns an array. If an element is a numeric, it represents the
        # kern amount to inject at that position. Otherwise, the element
        # is an array of UTF-16 characters.
        def kern(string)
          a = []
          
          string.unpack("U*").each do |r|
            if a.empty?
              a << [r]
            elsif (kern = kern_pairs_table[[cmap[a.last.last], cmap[r]]])
              kern *= scale_factor
              a << -kern << [r]
            else
              a.last << r
            end
          end

          a
        end

        # TODO: optimize resulting array further by compressing identical widths
        # into a single definition. E.g., turn:
        #
        #    [5, [1, 2, 3, 3, 3, 3, 3, 3, 4, 5]]
        #
        # into
        #
        #    [5, [1, 2], 8, 13, 3, 14, [4, 5]]
        def glyph_widths
          codes = cmap.code_map.keys.sort
          first_code = codes.shift
          widths = [first_code, [Integer(hmtx.for(cmap[first_code]).advance_width * scale_factor)]] 
          prev_code = first_code
          codes.each do |code|
            unless code == prev_code + 1
              widths << code
              widths << []
            end
            widths.last << Integer(hmtx.for(cmap[code]).advance_width * scale_factor )
            prev_code = code
          end
          widths
        end

        def bbox
          @bbox ||= @ttf.bbox.map { |i| Integer(i * scale_factor) }
        end

        def ascender
          @ascender ||= Integer(@ttf.ascent * scale_factor)
        end

        def descender
          @descender ||= Integer(@ttf.descent * scale_factor)
        end      
        
        def line_gap
          @line_gap ||= Integer(@ttf.line_gap * scale_factor)
        end

        def basename
          @basename ||= @ttf.name.postscript_name
        end

        def kern_pairs_table
          @kerning_data ||= has_kerning_data? ? @ttf.kerning.tables.first.pairs : {}
        end

        def has_kerning_data?
          @has_kerning_data 
        end

        def type0?
          true
        end

        # Perform any changes to the string that need to happen
        # before it is rendered to the canvas. Returns an array of
        # subset "chunks", where the even-numbered indices are the
        # font subset number, and the following entry element is
        # either a string or an array (for kerned text).
        #
        # The +text+ parameter must be UTF8-encoded.
        def encode_text(text,options={})
          text = text.chomp

          if options[:kerning]
            last_subset = nil
            kern(text).inject([]) do |result, element| 
              if element.is_a?(Numeric)
                result.last[1] = [result.last[1]] unless result.last[1].is_a?(Array)
                result.last[1] << element
                result
              else
                encoded = @subsets.encode(element)

                if encoded.first[0] == last_subset
                  result.last[1] << encoded.first[1]
                  encoded.shift
                end

                if encoded.any?
                  last_subset = encoded.last[0]
                  result + encoded
                else
                  result
                end
              end
            end
          else
            @subsets.encode(text.unpack("U*"))
          end
        end
        
        # not sure how to compute this for true-type fonts...
        def stemV
          0
        end

        def italic_angle
          @italic_angle ||= if @ttf.postscript.exists?
            raw = @ttf.postscript.italic_angle
            hi, low = raw >> 16, raw & 0xFF
            hi = -((hi ^ 0xFFFF) + 1) if hi & 0x8000 != 0
            "#{hi}.#{low}".to_f
          else
            0
          end
        end

        def cap_height
          @ttf.os2.exists? && @ttf.os2.cap_height || 0
        end

        def x_height
          @ttf.os2.exists? && @ttf.os2.x_height || 0
        end

        def family_class
          @family_class ||= (@ttf.os2.exists? && @ttf.os2.family_class || 0) >> 8
        end

        def serif?
          @serif ||= [1,2,3,4,5,7].include?(family_class)
        end

        def script?
          @script ||= family_class == 10
        end

        def pdf_flags
          @flags ||= begin
            flags = 0
            flags |= 0x0001 if @ttf.postscript.fixed_pitch?
            flags |= 0x0002 if serif?
            flags |= 0x0008 if script?
            flags |= 0x0040 if italic_angle != 0
            flags |= 0x0004 # assume the font contains at least some non-latin characters
          end
        end

        def cid_to_gid_map
          max = cmap.code_map.keys.max
          (0..max).map { |cid| cmap[cid] }.pack("n*")
        end

        private

        def hmtx
          @hmtx ||= @ttf.horizontal_metrics
        end

        def character_width_by_code(code)    
          return 0 unless cmap[code]
          @char_widths[code] ||= Integer(hmtx.widths[cmap[code]] * scale_factor)
        end                   

        def scale_factor
          @scale ||= 1000.0 / @ttf.header.units_per_em
        end

      end
    end
  end   
end
