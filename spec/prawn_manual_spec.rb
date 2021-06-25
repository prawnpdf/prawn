# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby', 'truffleruby'
    'de26db4fe63e024231c0a332203b41305103d877b584a2e98dbd0561bced39f2c066b5c0c96a4686e586a9deb347f099dac4c646446dadb1521a7d4a674ae6fb'
  when 'jruby'
    'c002ffaf6fe4b2877bd2244735e99c04a4b28b06bc365f343411af052d491660e0d858a956a757ad15a4ed16d6808fc8d726fd683d524f5a3f7c0c8b9566b683'
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
