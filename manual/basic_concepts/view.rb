# encoding: UTF-8
#
# To create a custom class that extends Prawn's functionality,
# use the <code>Prawn::View</code> mixin. This approach is safer than creating
# subclasses of <code>Prawn::Document</code> while being just as convenient.
#
# By using this mixin, your state will be kept completely separate
# from <code>Prawn::Document</code>'s state, and you will avoid accidental method
# collisions within <code>Prawn::Document</code>.
#
# To build custom classes that make use of other custom classes,
# you can define a method named <code>document()</code> that returns
# any object that acts similar to a <code>Prawn::Document</code>
# object. <code>Prawn::View</code> will then direct all delegated
# calls to that object instead.

require_relative "../example_helper"

class Greeter
  include Prawn::View

  def initialize(name)
    @name = name
  end

  def say_hello
    text "Hello, #{@name}!"
  end

  def say_goodbye
    font("Courier") do
      text "Goodbye, #{@name}!"
    end
  end
 end

greeter = Greeter.new("Gregory")

greeter.say_hello
greeter.say_goodbye

greeter.save_as("greetings.pdf")
