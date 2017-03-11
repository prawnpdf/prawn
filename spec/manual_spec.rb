require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'b55f154c9093c60f38051c75920c8157c775b946b0c77ffafc0a8a634ad5401e8ceafd0b96942839f82bacd726a690af3fdd1fd9e185616f67c6c0edfcfd0460'
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
