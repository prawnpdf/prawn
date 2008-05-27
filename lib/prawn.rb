# prawn.rb : A library for PDF generation in Ruby
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
           
require "prawn/compatibility"
require "prawn/errors"
require "prawn/pdf_object"
require "prawn/graphics"
require "prawn/document"
require "prawn/reference"  
require "prawn/font" 
require "prawn/info"
   
module Prawn 
  file = __FILE__
  file = File.readlink(file) if File.symlink?(file)
  dir = File.dirname(file)
                          
  # The base source directory for Prawn as installed on the system
  BASEDIR = File.expand_path(File.join(dir, '..'))    
end
