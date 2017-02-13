# To create a custom class that extends Prawn's functionality, use the
# <code>Prawn::View</code> mixin. This approach is safer than creating
# subclasses of <code>Prawn::Document</code> while being just as
# convenient.
#
# By using this mixin, your state will be kept completely separate
# from <code>Prawn::Document</code>'s state, and you will avoid
# accidental method collisions within <code>Prawn::Document</code>.
#
# You might define in your custom class a <code>document</code>
# instance method with a <code>Prawn::Document</code> initialized to
# your heart's content. This method will be called repeatedly by
# <code>Prawn::View</code>, so do not forget to assign the object to
# an instance variable via the <code>||=</code> operator.
#
# If you do not define the <code>document</code> method, a
# <code>Prawn::Document</code> will be lazily instantiated for you,
# using default initialization settings, such as page size, layout,
# margins, etc.
#
# Either way, your custom objects will have access to all
# <code>Prawn::Document</code> methods.

require_relative '../example_helper'

class Greeter
  include Prawn::View

  def initialize(name)
    @name = name
  end

  def say_hello
    text "Hello, #{@name}!"
  end

  def say_goodbye
    font('Courier') do
      text "Goodbye, #{@name}!"
    end
  end
end

greeter = Greeter.new('Gregory')

greeter.say_hello
greeter.say_goodbye

greeter.save_as('greetings.pdf')
