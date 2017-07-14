require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '9b2fde84364fdde4d879c4a29072bab38dfb89e3397923ae7a5a430e96fe7fb3c5dd59962152f47940b854a2d0806c555010258e03e8d462ae2feace8637c653'
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
