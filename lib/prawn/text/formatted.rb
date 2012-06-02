require "prawn/core/text/formatted/wrap"
require "prawn/text/formatted/box"
require "prawn/text/formatted/parser"
require "prawn/text/formatted/fragment"

module Prawn
  module Text
    module Formatted
      def self.register_parser(name, parser)
        @known_parsers ||= Hash.new
        @known_parsers[name] = parser
      end

      def self.unregister_parser(name)
        @known_parsers ||= Hash.new
        @known_parsers[name] = nil
      end

      def self.find_parser(name)
        @known_parsers ||= Hash.new
        @known_parsers[name]
      end

      def self.invoke_parser(name, string)
        extra_args = []

        if name.is_a?(Array)
          extra_args, name = name[1..-1], name.first
        end

        parser = self.find_parser(name) || Parser
        return parser.to_array(string, *extra_args)
      end
    end
  end
end
