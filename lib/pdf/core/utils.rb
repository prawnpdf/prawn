# frozen_string_literal: true

module PDF
  module Core
    module Utils
      module_function

      def deep_clone(object)
        Marshal.load(Marshal.dump(object))
      end
    end
  end
end
