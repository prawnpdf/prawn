# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'cfc8c0335d96952ec9e06e8509ba6e80af20e4ff5e8a75143f1e78ca36ddb56ff861dd285c65b5b823845ae2b4d7a4f9d538c5fbf376f50c89bb87b7dd3c6b51'
  when 'jruby'
    '30b10f71981d3dfbc087f18fe7aa98e67aaeaf5c0d97e30896b2edbda8de39e11031f13905ec093cbc1afe4e6e00ef22d9dcf8a27b8febf76f02120c2ebf187a'
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
