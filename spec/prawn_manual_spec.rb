# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '1fe48a34e5469554e69eb54797e929f1a12fe47c3b80d2ad7677419a99748488'\
    '0a769492acbd92874838ae27674d73766b2aa9d8ba9626d6d0dcc71565f80e78'
  when 'jruby'
    '1fe48a34e5469554e69eb54797e929f1a12fe47c3b80d2ad7677419a99748488'\
    '0a769492acbd92874838ae27674d73766b2aa9d8ba9626d6d0dcc71565f80e78'
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
