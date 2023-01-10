# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '85e288ee68c956b0144bf32559b69eb1eae0e4c05e41436299eb8e91f52872f0'\
    'd29272257b8cd79daa1033de73aadaf0c68d7744a23fe9fda86f45c9871748f4'
  when 'jruby'
    'a3dcec0745e16985fa2713dcaa6a1186b1a6a8c97096a3923893eebf128377ce'\
    '01228abf4d7335ae1e55984c0e973c4a57a036dd58345c6526cd082c0148082a'
  end

RSpec.describe Prawn do
  describe 'manual' do
    # JRuby's zlib is a bit quirky. It sometimes produces different output to
    # libzlib (used by MRI). It's still a proper deflate stream and can be
    # decompressed just fine but for whatever reason compression produces
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
