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

      # Sets the dash pattern for stroked lines and curves
      #
      #   length is the length of the dash. If options is not present,
      #   or options[:space] is nil, then length is also the length of
      #   the space between dashes
      #
      #   options may contain :space and :phase
      #      :space is the space between the dashes
      #      :phase is where in the cycle to begin dashing. For
      #             example, a phase of 0 starts at the beginning of
      #             the dash; whereas, if the phase is equal to the
      #             length of the dash, then stroking will begin at
      #             the beginning of the space. Default is 0
      #
      #   integers or floats may be used for length and the options
      #
      #   dash units are in PDF points ( 1/72 in )
      #   
      def dash(length=nil, options={})        
        return current_dash_state || undash_hash if length.nil?

        self.current_dash_state = { :dash  => length, 
                  :space => options[:space] || length, 
                  :phase => options[:phase] || 0 }

        write_stroke_dash
      end
      
      alias_method :dash=, :dash

      # Stops dashing, restoring solid stroked lines and curves
      #
      def undash
        self.current_dash_state = undashed_setting
        write_stroke_dash
      end
      
      # Returns when stroke is dashed, false otherwise
      #
      def dashed?
        current_dash_state != undashed_setting
      end
      
      def write_stroke_dash
        add_content dash_setting
      end

    private
      
      def undashed_setting
        { :dash => nil, :space => nil, :phase => 0 }
      end
      
      private 
        
      def current_dash_state=(dash_options)  
        graphic_state.dash = dash_options
      end
      
      def current_dash_state
        graphic_state.dash
      end
      
      def dash_setting
        graphic_state.dash_setting
      end
      
    end
  end
end
