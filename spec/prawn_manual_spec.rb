# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'fbc894c1e3645b43d9d113de812f00015cf01f5dc408be6b67ab69d62f719a92743534b8538a7eb11f516ee88ea647ca3dddfcc8f688c62701ff63aaa84239fe'
  when 'jruby'
    '51e6da9770b57e28f795e833ead8d981dd8867cfed90462c416c8e7dbfd1ae1fc7a69ddd98004aa0c2f77b5477902bb8da1bb2ecdffa09c3d8af6196ccaaf154'
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
