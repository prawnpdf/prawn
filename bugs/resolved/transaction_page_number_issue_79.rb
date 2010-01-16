# As of 2010.01.12, we have confirmed that page_number is not properly set on
# transaction rollback, resulting in an error from the code sample below.
#
# Resolved in 7c62bbf.
#

$LOAD_PATH << File.join(File.dirname(__FILE__), '..','lib')
require "prawn/core"

Prawn::Document.generate("transaction_rollback_pagenumber.pdf") do
  text "Hello world"

  transaction do
    text "hello " * 1000
    rollback
  end

  start_new_page
  text "hi there"
end

