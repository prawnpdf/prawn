# encoding: utf-8

# cmap.rb : class for building ToUnicode CMaps for Type0 fonts
#
# Copyright May 2008, Gregory Brown / James Healy. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Font #:nodoc:
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
        res =  "12 dict begin\n"
        res << "begincmap\n"
        res << "/CIDSystemInfo\n"
        res << "<< /Registry (Adobe)\n"
        res << "/Ordering (UCS)\n"
        res << "/Supplement 0\n"
        res << ">> def\n"
        res << "/CMapName /Adobe-Identity-UCS def\n"
        res << "/CMapType 2 def\n"
        res << "begincodespacerange\n"
        res << "<0000> <ffff>\n"
        res << "endcodespacerange\n"
        res << "9 beginbfchar\n"
        @codes.keys.sort.each do |key|
          val = @codes[key]
          ccode = val.to_s(16)
          ccode = ("0" * (4 - ccode.size)) + ccode
          unicode = key.to_s(16)
          unicode = ("0" * (4 - unicode.size)) + unicode
          res << "<#{ccode}> <#{unicode}>\n"
        end
        res << "endbfchar\n"
        res << "endcmap\n"
        res << "CMapName currentdict /CMap defineresource pop\n"
        res << "end\n"
        res << "end\n"
      end
    end
  end
end
