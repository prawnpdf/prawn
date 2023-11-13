# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '0abebec8ea1965b032ba737aec56475ace1098ba2573c048cd6a5c019fa898f1c0d103fbd0a53493e63db2569144635fdd8c76d4fbb916149a7936484ef20629'
  when 'jruby'
    '51baf6440907e9e38d22f50deafa91572aec1174e621c044ae077cfe3d4361982a505dae5f013dd06f64f38cb9b3a38d5a3f8f0903849591774e298a3c91d39a'
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
