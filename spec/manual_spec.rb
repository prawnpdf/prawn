require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '6aae613c48e7d9f7d4f57f026fe7c70eddff0bda8698ce7e8720bcd8c72ba1ca48f795aff153c39669e9282ee7350aeeabc39dd7051269cba95ae4a06e7437c8'
  when 'jruby'
    '483874116106a5f6276a1f196c6e72f9f823c613108512431d4e805ef5f03387d7a1a05a481540eebde8f86cba254f231d5b56872857c2e27900effccd2804f9'
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
