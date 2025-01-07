# frozen_string_literal: true

module Prawn
  # Useful for comparing floats for equality to avoid precision errors.
  # Based on pdf-core output precision: https://github.com/prawnpdf/pdf-core/blob/1021ffc94b9d8d37854ef5199d3cbaf220bb5ab2/lib/pdf/core/pdf_object.rb#L16
  FLOAT_PRECISION_DELTA = 1e-6

  # Throughout the Prawn codebase, repeated calculations which can benefit from
  # caching are made.  n some cases, caching and reusing results can not only
  # save CPU cycles but also greatly reduce memory requirements But at the same
  # time, we don't want to throw away thread safety.
  # @private
  class SynchronizedCache
    # As an optimization, this could access the hash directly on VMs with
    # a global interpreter lock (like MRI).
    def initialize
      @cache = {}
      @mutex = Mutex.new
    end

    # Get cache entry.
    #
    # @param key [any]
    # @return [any]
    def [](key)
      @mutex.synchronize { @cache[key] }
    end

    # Set cache entry.
    #
    # @param key [any]
    # @param value [any]
    # @return [void]
    def []=(key, value)
      @mutex.synchronize { @cache[key] = value }
    end
  end
end
