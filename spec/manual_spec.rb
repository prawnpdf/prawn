require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '8365f44414803dd732897bf22f307fd2b384b3d7d3e7f39324364a5967af8412a32cfb88300da55b8152c31e5b1090a7713caa307f1de94fadeddbe06f0717c9'
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
