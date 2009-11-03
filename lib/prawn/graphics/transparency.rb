# encoding: utf-8
#
# transparency.rb : Implements transparency
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Graphics
    module Transparency

      def transparent(opacity, stroke_opacity=opacity, &block)
        min_version(1.4)

        key = "#{opacity}_#{stroke_opacity}"

        if opacity_dictionary_registry[key]
          opacity_dictionary =  opacity_dictionary_registry[key][:obj]
          opacity_dictionary_name =  opacity_dictionary_registry[key][:name]
        else
          opacity_dictionary = ref!(:Type => :ExtGState,
                                    :CA   => stroke_opacity,
                                    :ca   => opacity
                                    )

          opacity_dictionary_name = "Tr#{next_opacity_dictionary_id}"
          opacity_dictionary_registry[key] = { :name => opacity_dictionary_name, 
                                               :obj  => opacity_dictionary }
        end

        page_ext_gstates.merge!(opacity_dictionary_name => opacity_dictionary)

        # push a new graphics context onto the graphics context stack
        add_content "q"
        add_content "/#{opacity_dictionary_name} gs"

        yield if block_given?

        add_content "Q"
      end

      private

      def opacity_dictionary_registry
        @opacity_dictionary_registry ||= {}
      end

      def next_opacity_dictionary_id
        opacity_dictionary_registry.length + 1
      end

    end
  end
end
