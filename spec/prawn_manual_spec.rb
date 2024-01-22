# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '7991e4f72e944140840e1c26f0fff331029846eaab148de8483d06491c7808bc4963e8e7376a514e855037f1f1b4197877a31f2df44f511f4f7f5e0ce5df3170'
  when 'jruby'
    '29b8f8cb00910426805ce226fb47c59d6409683f35f0d2c056a6cf837ba086ca5c763ff89266cfc8e11b1d92af60c9974822b12ad761cdbdf520adb005a98750'
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
