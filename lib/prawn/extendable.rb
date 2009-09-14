# coding: utf-8

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
