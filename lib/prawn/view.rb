# encoding: UTF-8

module Prawn
  module View
    def document
      @document ||= Prawn::Document.new
    end

    def method_missing(m, *a, &b)
      document.send(m, *a, &b)
    rescue NoMethodError
      super
    end

    def update(&b)
      instance_eval(&b)
    end

    def save_as(filename)
      document.render_file(filename)
    end
  end
end
