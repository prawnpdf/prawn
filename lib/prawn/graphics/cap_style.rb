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
      # Sets the cap_style for stroked lines and curves
      #

      CAP_STYLES = { :butt => 0, :round => 1, :projecting_square => 2 }
      
      # style is one of :butt, :round, or :projecting_square
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
