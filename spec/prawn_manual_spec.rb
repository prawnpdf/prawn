# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '48636dc37d18766288331a57e4b24d14623e37aa6381c542ec3dc5cb600c403d'\
    '2e845509d65beaa83fec7ab67335767625fce111c37a7351f0fba3b167ea6ff1'
  when 'jruby'
    'bde976693864dbddddcb296070558458a0bdcbe1d6338da4e99d58ada972ad70'\
    '60c85b953445fb55606fb28865b3e10c080cef5b20df185f0a888da819ff0334'
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
