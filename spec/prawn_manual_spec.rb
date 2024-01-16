# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'ab45a1e814006cb04928f8d0f6c9d0a409c90ffb41dc2fd10e3558e7b314fb99d2a0f5aa29b89a6ae855eaa4ed9840620abbc8bab9c48991aa7f69a98550fa79'
  when 'jruby'
    '475e2df3b691db5b2934d4ff0598cbd69dae26a60840b66d2a2eadc1d2bc30e24c83ba4fea9305a77f42e515d5cf5ffdc8a83587686fb17461cda0c7ad97c364'
  end

RSpec.describe Prawn do
  describe 'manual' do
    # JRuby's zlib is a bit quirky. It sometimes produces different output to
    # libzlib (used by MRI). It's still a proper deflate stream and can be
    # decompressed just fine but for whatever reason compressin produses
    # different output.
    #
    # See: https://github.com/jruby/jruby/issues/4244
    it 'contains no unexpected changes' do
      ENV['CI'] ||= 'true'

      require File.expand_path(File.join(__dir__, %w[.. manual contents]))
      s = prawn_manual_document.render

      hash = Digest::SHA512.hexdigest(s)

      expect(hash).to eq MANUAL_HASH
    end
  end
end
