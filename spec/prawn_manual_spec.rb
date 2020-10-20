# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '7bbbcaea6a40c9d2386c02a9ab70bafdefc450c71092feb3791079c5988019ae'\
    'c7841cf9b55cb08b66aafc626747afc8f763e7d36dbbcfcc88b13b96097e831b'
  when 'jruby'
    '7bbbcaea6a40c9d2386c02a9ab70bafdefc450c71092feb3791079c5988019ae'\
    'c7841cf9b55cb08b66aafc626747afc8f763e7d36dbbcfcc88b13b96097e831b'
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
