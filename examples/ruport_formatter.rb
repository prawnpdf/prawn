$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
require "rubygems"
require "ruport"

module Ruport
  class Formatter 
    class PrawnPDF < Ruport::Formatter
      renders :pdf, :for => Ruport::Controller::Table

      def document
        @document ||= (options.document || Prawn::Document.new)
      end

      def table_body
        data.map { |e| e.to_a }
      end

      build :table_header do
        @headers = options.headers || data.column_names
      end

      build :table_body do
        document.table table_body, 
          :headers            => @headers, 
          :row_colors         => :pdf_writer,
          :position           => :center,
          :font_size          => 10,
          :vertical_padding   => 2,
          :horizontal_padding => 5
      end

      def finalize
        output << document.render
      end

    end
  end
end

if __FILE__ == $PROGRAM_NAME
  t = Table("#{Prawn::BASEDIR}/examples/addressbook.csv")
  headers = t.column_names.map { |c| c.capitalize }
  t.save_as "addressbook_ruport.pdf", :headers => headers
end
