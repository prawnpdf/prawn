require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'c7202f015e36d02ac36dac38d88bb78a4dd439ec6d23268ebddaa15a8bcf7e790f203fd3e92d9c1b92c1a2806a03d7f5706c1550da29f281d25bb5540568445e'
  when 'jruby'
    'd2eb71ea3ddc35acb185de671a6fa48862ebad5727ce372e3a742f45d31447765c4004fbe5fbfdc1f5a32903ac87182c75e6abe021ab003c8af6e6cc33e0d01e'
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
