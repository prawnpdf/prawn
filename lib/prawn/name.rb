module Prawn
  class Name < String
    def to_s
      "/" + super
    end
  end
end
