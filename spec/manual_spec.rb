# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'd8b6b220c2ce749f45108cab3a9e710ade90b1316a3e01a64ddd65f389c06bf95af8d1ff6086a5b3e1b1c7da001f577199e7de12e09545af01751b05e3a70c93'
  when 'jruby'
    '6cc8210b82540a46c1e3700fe4317f5b1043b1aa61fffc16d2591d1d350d8f392bb84f206c35f4032130a883273f8342ddeae45790bc203c570efc5426115b53'
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
