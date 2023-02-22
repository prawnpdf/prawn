# frozen_string_literal: true

module PDF
  module Core
    class FilterList
      class NotFilter < StandardError
        DEFAULT_MESSAGE = 'Can not interpret input as a filter'
        MESSAGE_WITH_FILTER = 'Can not interpret input as a filter: %<filter>s'

        def initialize(message = DEFAULT_MESSAGE, filter: nil)
          if filter
            super format(MESSAGE_WITH_FILTER, filter: filter)
          else
            super(message)
          end
        end
      end

      def initialize
        @list = []
      end

      def <<(filter)
        case filter
        when Symbol
          @list << [filter, nil]
        when ::Hash
          filter.each do |name, params|
            @list << [name, params]
          end
        else
          raise NotFilter.new(filter: filter)
        end

        self
      end

      def normalized
        @list
      end
      alias to_a normalized

      def names
        @list.map do |(name, _)|
          name
        end
      end

      def decode_params
        @list.map do |(_, params)|
          params
        end
      end

      def inspect
        @list.inspect
      end

      def each(&block)
        @list.each(&block)
      end
    end
  end
end
