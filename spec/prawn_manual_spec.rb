# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '1afdc3033cc45794a808b0ec3cfab3243270cda23d63c856130363915f59a012'\
    '9277e276b4da56d04859209d3c99f823e20aeba82bc2aa5ed84acab531bb128c'
  when 'jruby'
    '1afdc3033cc45794a808b0ec3cfab3243270cda23d63c856130363915f59a012'\
    '9277e276b4da56d04859209d3c99f823e20aeba82bc2aa5ed84acab531bb128c'
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
