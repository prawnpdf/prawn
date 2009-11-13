# http://github.com/sandal/prawn/issues#issue/56
#
# As of f952055d03f9b21b78ec2844bd873cf62005d00a
# Transactions fail when using TTF fonts.
#
# This is because we use an on_encode Proc that gets included in the 
# @current_page object, which breaks snapshots.  We can surely write
# around this to either split out the Proc into non-marshalled data
# or set up some sort of callback that is indicated by something that
# can be safely marshalled.
#
# But whoever tackles this patch should take care to ensure we
# don't break TTF subsetting support, adding specs if necessary.
#
require 'prawn/core' 

Prawn::Document.generate("err.pdf") do
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  text "Hi there"
  transaction { text "Nice, thank you" }
end
