# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '0991412856bb7eb030d53d2e0ed5b3044c42d00db612c330a58ca233dc79d15e'\
    '63852257984af2bd17223a92a210e84c1ee46d18abc65ce64356fe0bd90b05e9'
  when 'jruby'
    '0991412856bb7eb030d53d2e0ed5b3044c42d00db612c330a58ca233dc79d15e'\
    '63852257984af2bd17223a92a210e84c1ee46d18abc65ce64356fe0bd90b05e9'
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
