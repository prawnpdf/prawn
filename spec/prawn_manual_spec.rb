# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'a2a111c8b3ef808b734c506dc9184520888bc5904c2eb12ab299a634d63e9e0f9ede52e54a701f346a3b48364c9e48ebb82a6b2351becde08e2382fe349158a9'
  when 'jruby'
    'eb3742d593861f6ca35667198b796265a58ac63aecdb8415bdee2d191f83341bb466e3b3c136a8609acf9e7c589612fe8b19d97f99cfc183d78962c6e2aa3546'
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
