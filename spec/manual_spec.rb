require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'fe164bfaa92b32a06c3fba6499910ff0896b6d720156c3d36cf22fafbb2ecc0bd481bedf11bf78963e50a13134b83d1a9f51f3dd73cff7cad464467902de51f1'
  when 'jruby'
    '8d787577a92e2c3a8c4924911cf93b29dcaec6ba729a3a90d036b18252f499d444fb23c78e14d5bf4861a0d6fa6d1eae4771d229c938957f54786a9cc8fe1a80'
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
