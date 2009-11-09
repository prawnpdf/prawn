# coding: utf-8

module Prawn
  module Extendable
    def extensions
      @extensions ||= [ ]
    end
    
    def new(*args, &block)
      o = super
      o.extend(*extensions.reverse) unless extensions.empty?
      o
    end
  end
end
