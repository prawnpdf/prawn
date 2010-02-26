module PDF
  class Inspector
    class ExtGState < Inspector
      attr_accessor :extgstates

      def initialize
        @extgstates = []
      end

      def resource_extgstate(*params)
        @extgstates << {
                        :opacity => params[1][:ca],
                        :stroke_opacity => params[1][:CA]
                        }
      end
    end
  end
end
