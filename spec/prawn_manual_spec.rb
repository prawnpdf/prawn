# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  {
    'ruby' => '2c0279e0bff2a9120494a52aa46216c1871902b5e66a3537bd4d3cbd66db0096b43b6e1ae0e4e189b561c4db9fa1afacb6c41f260e3aaf942faae2fee352d35b',
    'jruby' => '51baf6440907e9e38d22f50deafa91572aec1174e621c044ae077cfe3d4361982a505dae5f013dd06f64f38cb9b3a38d5a3f8f0903849591774e298a3c91d39a',
    'truffleruby' => '2d001a18e27582cce60a6610ca0239de96e7413b0c2a657af5ef364cdc793f3ecd22fbf0ca88bd33cbc24f08cbf0f055cc24a9c2661087047b8ddd14c4554fa5'
  }.freeze

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

      expect(hash).to eq MANUAL_HASH[RUBY_ENGINE]
    end
  end
end
