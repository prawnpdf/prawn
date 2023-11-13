# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '0abebec8ea1965b032ba737aec56475ace1098ba2573c048cd6a5c019fa898f1c0d103fbd0a53493e63db2569144635fdd8c76d4fbb916149a7936484ef20629'
  when 'jruby'
    '04c7933ba701ef23acb2f5e02d41f2bcb593f39237eebe3089b5f7a55a2afc61361f2f98a31a7239de593e0573a7e1ccbd3d7930510029fc53fa9f23a6e5e97d'
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
