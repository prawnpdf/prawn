require 'nokogiri'
require 'open3'

module Prawn
  module VeraPdf
    VERA_PDF_EXECUTABLE = 'verapdf'.freeze
    VERA_PDF_COMMAND = "#{VERA_PDF_EXECUTABLE} --flavour 1b --format xml".freeze

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      return nil
    end

    def vera_pdf_available?
      which VERA_PDF_EXECUTABLE
    end

    def valid_pdfa_1b?(pdf_data)
      stdout, stderr, status = Open3.capture3(VERA_PDF_COMMAND, stdin_data: pdf_data)
      raise Exception, "VeraPDF could not be run. #{stderr}" unless status.success?

      reported_as_compliant? stdout.lines[4..-1].join
    end

    def reported_as_compliant?(xml_data)
      xml_doc = Nokogiri::XML xml_data
      raise Exception, 'The veraPDF xml report was not well formed.' unless xml_doc.errors.empty?

      xml_doc.remove_namespaces!
      validation_result = xml_doc.xpath('/processorResult/validationResult')
      assertions = validation_result.xpath('assertions/assertion')
      assertions.each do |assertion|
        message = assertion.at_xpath('message').content
        clause = assertion.at_xpath('ruleId').attribute('clause').content
        test = assertion.at_xpath('ruleId').attribute('testNumber').content
        context = assertion.at_xpath('location/context').content
        url = 'https://github.com/veraPDF/veraPDF-validation-profiles/wiki/PDFA-Part-1-rules'
        url_anchor = "rule-#{clause.delete('.')}-#{test}"
        puts
        puts 'PDF/A-1b VIOLATION'
        puts "  Message: #{message}"
        puts "  Context: #{context}"
        puts "  Details: #{url}##{url_anchor}"
        puts
      end
      validation_result.attribute('isCompliant').content == 'true'
    end
  end
end
