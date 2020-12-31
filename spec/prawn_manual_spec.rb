# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '79248d58f9d89e44081da875fa15ad9a70cc07e9eaa4e8b706001044a3570e3f'\
    'bc4b5ba3e1150868d88add3a43972265219d4d11c60cbbc1bebf50e7d26cdb60'
  when 'jruby'
    '22cf478cc5563cf0283d239ca5e87df44151fb422b5fd426c3aec47ca1df44fa'\
    '7b3826131d65cadad5430a05ee812000ae9f9419d6bc5ba4024fdf6a799fc184'
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
