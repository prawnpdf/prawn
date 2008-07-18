#--
# PDF::Writer for Ruby.
#   http://rubyforge.org/projects/ruby-pdf/
#   Copyright 2003 - 2005 Austin Ziegler.
#
#   Licensed under a MIT-style licence. See LICENCE in the main distribution
#   for full licensing information.
#
# $Id$
#++
module Prawn
  module Images
    module OffsetReader
      def read_o(length = 1, offset = nil)
        @offset ||= 0
        @offset = offset if offset
        ret = self[@offset, length]
        @offset += length
        ret
      end
      def offset
        @offset
      end
      def offset=(o)
        @offset = o || 0
      end
    end
  end
end
