# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'e377c63992ee452d7797e8f1bed32caaa875931f37db5e99017c404e65fee7b0'\
    '926877f940aa23f3957f18c5f3e88524250c3139e9af7766177ecf6504cdaab2'
  when 'jruby'
    'e377c63992ee452d7797e8f1bed32caaa875931f37db5e99017c404e65fee7b0'\
    '926877f940aa23f3957f18c5f3e88524250c3139e9af7766177ecf6504cdaab2'
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
