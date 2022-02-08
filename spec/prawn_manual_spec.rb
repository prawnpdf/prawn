# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '1dbd5d466eb58d4d495aee6869eb839e3995fbe8607318c491786b959f490e5aab968574a2fea8c3e42ef3d54374bc903357f5cc7b5065f5fe71999830d7c995'
  when 'jruby'
    'e23a8336dd55ca007d93eaaacb9ef6ca4d3e91d4b6ccf5e504925212907ebf3a0c7334e1a614ee5e54de800bd4500a3b2430e038bd9f75879c4a69c68589408d'
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
