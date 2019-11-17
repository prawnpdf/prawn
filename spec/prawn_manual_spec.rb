# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'ea401febcaf2d71a374bc7f25753568ec07dde3479597091498acf4c42c7fd6f'\
    '9a94f4a42e5b366b947cc0c2623a3a6c6990cd7a9bbffa63babd1c61290c1ad6'
  when 'jruby'
    'c7511076e6b38fb06e0af4e761327d640f692a63cba2322317d247d81f5d1974'\
    'd2c02882bed80e5b06b521b879c91d1bfe7008b781e0b2f8e55b54f0fe615988'
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
