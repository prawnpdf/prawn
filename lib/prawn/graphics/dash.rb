# encoding: utf-8   

# dash.rb : Implements stroke dashing
#
# Contributed by Daniel Nelson. October, 2009
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Graphics
    module Dash
      # Sets the stroking dash pattern. The first argument is the
      # length, in current units, of the dash. The second argument is
      # the length of the space between dashes. The third argument is
      # the phase, that is, where in the dash-space cycle the dashing
      # will begin. Integer or float values may be used for the dash
      # and space lengths. Integer for the phase.
      #
      # If only one argument is provided, the empty space will be the
      # same length as the solid dash

      def set_stroke_dash(dash_length=nil, space_length=dash_length, phase=0)
        @stroke_dash = { :dash => dash_length, :space => space_length, :phase => phase }
        write_stroke_dash
      end
      
      # Restores solid stroking
      def clear_stroke_dash
        set_stroke_dash(nil)
      end
      
      # Returns true iff the stroke is dashed
      def dashed_stroke?
        stroke_dash != solid_stroke_hash
      end

      # Returns the hash defining the current dash settings
      def stroke_dash
        return @stroke_dash || solid_stroke_hash
      end

      private

      def solid_stroke_hash
        { :dash => nil, :space => nil, :phase => 0 }
      end

      def write_stroke_dash
        if @stroke_dash[:dash].nil?
          add_content "[] 0 d"
          return
        end
        add_content "[#{@stroke_dash[:dash]} #{@stroke_dash[:space]}] #{@stroke_dash[:phase]} d"
      end     
    end
  end
end
