require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'a34b4a7360ee8525a8124a1a93f279e5bcbad8bccda39f3e881633718f81e20377cc4244eb312b0c072daf46209ffad488b16c2beb8bd0ea2deeda06c7bc94f8'
  when 'jruby'
    'cba8a89af8ea5f769f16eccb102c05e7b4e66e286282e4225423a97631076737bb2c136c4788cb89dc3c8e5d8d92120e7854fb5003869d2b31fdb9c34167a690'
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
