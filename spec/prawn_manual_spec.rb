# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '2caaa75cc4c48b790e43263b4912f66dec759719e8d06ca2ba5604d94ee5cf9f'\
    '947ced53e1187c1f8aa59e63942075dabb7426c7df079d8a8d030051061c751e'
  when 'jruby'
    '191b6f5bc9f6419e3f7c126bb570b783e65a033d0581e16ed2219b436e05063e'\
    '9d4edd8c94f183bbb4ca2a298a6d31dc4d6ae7bef30052074aeb725e8cf75314'
  end

RSpec.describe Prawn do
  describe 'manual' do
    # JRuby's zlib is a bit quirky. It sometimes produces different output to
    # libzlib (used by MRI). It's still a proper deflate stream and can be
    # decompressed just fine but for whatever reason compression produces
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
