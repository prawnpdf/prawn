# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'cc870b1f374b1da862c7bd08fa9f23c2815b4a12616b734e8dc30a8226ed307cb11503ec4621bb935bec3bd94837a32c1b186f493a0e3c2137cb8e1122518ba0'
  when 'jruby'
    '3583b193ec8698ba752916b8a4c37cd9d2d90f1bf7284922759c3e10b41e36e146149f12e2f96ae7716915089ff6f82945895a5de7d1f536f749404d1c1b1627'
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

      manual_path = File.expand_path('../manual/manual.rb', __dir__)
      manual = eval(File.read(manual_path), TOPLEVEL_BINDING, manual_path) # rubocop: disable Security/Eval
      s = manual.generate

      hash = Digest::SHA512.hexdigest(s)

      expect(hash).to eq MANUAL_HASH
    end
  end
end
