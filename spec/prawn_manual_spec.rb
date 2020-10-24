# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '59c0acffd3c75588de2f1df60bb6af857a7c8b50c9e551bdc930af32e6a4eee6'\
    '061561812a17384a5345f06ff770d7022d1f1d1f1da7d9ac0d01e805532c1287'
  when 'jruby'
    'f4e45385bfebe797d97c46046ea585434d45de3e70e7f6a2f9d77445daadf5be'\
    'aaa3c6bf52664280334356e01bfa275b0184a7bb18d2f2499286b00c99df2741'
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
