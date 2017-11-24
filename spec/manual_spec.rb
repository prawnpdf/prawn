require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'f05c4f738f0be06e99c645aa4cbc4c4a8ed5c68ccf572b8ea880f9eba7a64dc36c4c5499f660261c9f45da649846fc37bad0597512d4f4777a76776bb737df0d'
  when 'jruby'
    'ccda8bed9077867c7cecf62579f486214ac87b7a451f6b78f000795ae8ff5347ffca04f57e251bf15a088470f2c86884a3a7d37bb566858dd9bbf60b2925d798'
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
