# encoding: utf-8   

# cap_style.rb : Implements stroke cap styling
#
# Contributed by Daniel Nelson. October, 2009
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Graphics
    module CapStyle

      CAP_STYLES = { :butt => 0, :round => 1, :projecting_square => 2 }
      
      # Sets the cap style for stroked lines and curves
      #
      # style is one of :butt, :round, or :projecting_square
      #
      # NOTE: If this method is never called, :butt will be used by default.
      #
      def cap_style(style=nil)
        return @cap_style || :butt if style.nil?

        @cap_style = style

        write_stroke_cap_style
      end
      
      alias_method :cap_style=, :cap_style

      private

      def write_stroke_cap_style
        add_content "#{CAP_STYLES[@cap_style]} J"
      end
    end
  end
end
