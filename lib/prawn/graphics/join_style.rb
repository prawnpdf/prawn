# encoding: utf-8   

# join_style.rb : Implements stroke join styling
#
# Contributed by Daniel Nelson. October, 2009
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Graphics
    module JoinStyle
      # Sets the join_style for stroked lines and curves
      #

      JOIN_STYLES = { :miter => 0, :round => 1, :bevel => 2 }
      
      # style is one of :miter, :round, or :bevel
      def join_style(style=nil)
        return @join_style || :miter if style.nil?

        @join_style = style

        write_stroke_join_style
      end
      
      alias_method :join_style=, :join_style

      private

      def write_stroke_join_style
        add_content "#{JOIN_STYLES[@join_style]} j"
      end
    end
  end
end
