# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'c174bf623f6ff0b7140e74c38d6bea3ca0c28f07e9883b8e10f136fb91ed38ef2e62f0653ed1d23ff83f94bbd1af9b372998e0a8d5ec5bbc05709648ed5c7f6a'
  when 'jruby'
    '51baf6440907e9e38d22f50deafa91572aec1174e621c044ae077cfe3d4361982a505dae5f013dd06f64f38cb9b3a38d5a3f8f0903849591774e298a3c91d39a'
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
