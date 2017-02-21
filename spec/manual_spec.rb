require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'b213efa532c7f2a159f69ee5559efe95333810e302ea09f60772ffdea6bb74eb477d6e7411454ba58376cf75e17bc6f7181eee991ac5d7d0c0bac71c9892a41c'
  when 'jruby'
    '0d65981e685d44c83d4ed1b0c7266da0d2b2d7c749d5d332b6837a29d44a808d03ee2ed09a9a6cf9105cf90f8a6af44dad4a5f152e6a11b05561a74ddf54b643'
  end
# rubocop: enable Metrics/LineLength

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
