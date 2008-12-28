# encoding: utf-8

# cmap.rb : class for building ToUnicode CMaps for Type0 fonts
#
# Copyright May 2008, Gregory Brown / James Healy. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Font 
    class CMap #:nodoc:

      def initialize
        @codes = {}
      end

      def [](c)
        @codes[c]
      end

      def []=(c, v)
        @codes[c] = v
      end

      def to_s
        # TODO: learn what all this means. I just copied the basic structure
        #       from an existing PDF
        # TODO: make this more efficient. The mapping can be specified in
        #       ranges instead of one -> one
        res =  "/CIDInit /ProcSet findresource begin\n"
        res << "12 dict begin\n"
        res << "begincmap\n"
        res << "/CIDSystemInfo\n"
        res << "<< /Registry (Adobe)\n"
        res << "/Ordering (UCS)\n"
        res << "/Supplement 0\n"
        res << ">> def\n"
        res << "/CMapName /Adobe-Identity-UCS def\n"
        res << "/CMapType 2 def\n"
        res << "1 begincodespacerange\n"
        res << "<0000> <ffff>\n"
        res << "endcodespacerange\n"

        glyphs = @codes.invert
        ranges = []

        run = nil
        glyphs.keys.sort.each do |key|
          next if key == 0
          val = glyphs[key]

          if run && val == run[:last]+1
            run[:end] = key
            run[:last] = val
          else
            if run
              ranges << "<%04X> <%04X> <%04X>" % [run[:start], run[:end], run[:from]]
            end

            run = { :start => key, :end => key, :from => val, :last => val }
          end
        end

        ranges << "<%04X> <%04X> <%04X>" % [run[:start], run[:end], run[:from]] if run

        res << "%d beginbfrange\n" % ranges.length
        res << ranges.join("\n") << "\n"
        res << "endbfrange\n"
        res << "endcmap\n"
        res << "CMapName currentdict /CMap defineresource pop\n"
        res << "end\n"
        res << "end"
      end
    end
  end
end
