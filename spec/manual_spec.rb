require "spec_helper"
require "digest/sha2"

RSpec.describe "Manual" do
  it "contains no unexpected changes" do
    ENV["CI"] ||= "true"

    require File.expand_path(File.join(File.dirname(__FILE__), %w[.. manual contents]))
    s = prawn_manual_document.render

    hash = Digest::SHA512.hexdigest(s)

    expect(hash).to eq "795647cddbeea7e32a34298d941f675fcdd23511c4eec6d7dd92cf98d3e438261f0779d8863321e7b39826fb047ed77018e88fc0ab8754fb62655535e678be17"
  end
end
