require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'ac6e99bf22dd31c21c95295ae7b956a610ce98afcbae2e23df1648e0128b3be8728342d6d9622c73ff3702506e8b00d43557d19a77e7ebc313e8133155568efd'
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
