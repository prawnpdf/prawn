# encoding: utf-8
#
# transparency.rb : Implements transparency
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Transparency
    # , &block
    #  raise "block required" unless block_given?
    def set_opacity(opacity, stroke_opacity=opacity)
      min_version(1.4)
      key = "#{opacity}_#{stroke_opacity}"
      if opacity_dictionary_registry[key]
        opacity_dictionary =  opacity_dictionary_registry[key][:obj]
        opacity_dictionary_name =  opacity_dictionary_registry[key][:name]
      else
        opacity_dictionary = ref!(:Type => :ExtGState,
                                  :CA   => :stroke_opacity,
                                  :ca   => :opacity
                                  )
        
        opacity_dictionary_name = "T#{next_opacity_dictionary_id}"
        opacity_dictionary_registry[key] << { :name => dictionary_name, :obj => opacity_dictionary }
        # /Resources must include /ExtGState << /TranspLib1 N 0 R
        # /TranspLib2 N2 0 R /TranspLibN NN 0 R >>

        # need an object << /Type /ExtGState
        #                   /CA stroke opacity
        #                   /CA non-stroke-opacity

        # everywhere a dictionary is used, we write "/TranspLibN gs"
      end
    end

    private

    def opacity_dictionary_registry
      @opacity_dictionary_registry ||= {}
    end

    def next_opacity_dictionary_id
      opacity_dictionary_registry.count
    end
  end
end
