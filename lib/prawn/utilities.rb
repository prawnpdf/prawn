# encoding: utf-8

# utilities.rb : General-purpose utility classes which don't fit anywhere else
#
# Copyright August 2012, Alex Dowad. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'thread'

module Prawn

  # Throughout the Prawn codebase, repeated calculations which can benefit from caching are made
  # In some cases, caching and reusing results can not only save CPU cycles but also greatly
  #   reduce memory requirements
  # But at the same time, we don't want to throw away thread safety
  # We have two interchangeable thread-safe cache implementations:

  # @private
  class SynchronizedCache 
    # As an optimization, this could access the hash directly on VMs with a global interpreter lock (like MRI)
    def initialize
      @cache = {}
      @mutex = Mutex.new
    end
    def [](key)
      @mutex.synchronize { @cache[key] }
    end
    def []=(key,value)
      @mutex.synchronize { @cache[key] = value }
    end
  end
  
  # @private
  class ThreadLocalCache     
    def initialize
      @cache_id = "cache_#{self.object_id}".to_sym
    end
    def [](key)
      (Thread.current[@cache_id] ||= {})[key]
    end
    def []=(key,value)
      (Thread.current[@cache_id] ||= {})[key] = value
    end
  end
end
