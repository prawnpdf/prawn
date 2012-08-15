# encoding: utf-8

require "coderay"

# Registers a to_prawn method on CodeRay. It returns an array of hashes to be
# used with formatted_text.
#
# Usage:
#
# CodeRay.scan(string, :ruby).to_prawn
#
class PrawnEncoder < CodeRay::Encoders::Encoder
  register_for :to_prawn

  COLORS = { :default           => "FFFFFF",
             
             :comment           => "AEAEAE",
             :constant          => "88A5D2",
             :instance_variable => "E8ED97",
             :integer           => "C8FF0E",
             :float             => "C8FF0E",
             :inline_delimiter  => "EF804F",  # #{} within a string
             :keyword           => "FEE100",
             
             # BUG: There appear to be some problem with this token. Method
             #      definitions are considered as ident tokens
             #
             :method            => "FF5C00",
             :string            => "56D65E",
             :symbol            => "C8FF0E" 
           }

  def setup(options)
    super
    @out  = []
    @open = []
  end

  def text_token(text, kind)
    color = COLORS[kind] || COLORS[@open.last] || COLORS[:default]
    
    @out << {:text => text, :color => color}
  end

  def begin_group(kind)
    @open << kind
  end

  def end_group(kind)
    @open.pop
  end
end
