# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '8ace5f35f945e5994647cefc2cf7bc369d131e0646d91eb8aeb94e58f72de18d8e7bf82f58fc45406110c4adad239dcbe834059580d29fec2b2a039db67db04c'
  when 'jruby'
    'b77a740d3290192360c4c083018ca61ccc88d42e7c6a152c7bc394d751f5f08d85aec613549f6660713644b00518561cc0f9c947701f01e8c25632c9db81201a'
  end

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
