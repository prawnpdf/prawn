require 'rexml/document'
require 'open3'

module VeraPdfHelpers
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
    xml_doc = REXML::Document.new xml_data
    xml_doc.elements.each('/processorResult/validationResult/ns2:assertions/ns2:assertion') do |element|
      message = element.elements.to_a('ns2:message').first.text
      clause = element.elements.to_a('ns2:ruleId').first.attributes['clause']
      test = element.elements.to_a('ns2:ruleId').first.attributes['testNumber']
      context = element.elements.to_a('ns2:location/ns2:context').first.text
      url = 'https://github.com/veraPDF/veraPDF-validation-profiles/wiki/PDFA-Part-1-rules'
      url_anchor = "rule-#{clause.delete('.')}-#{test}"
      puts
      puts 'PDF/A-1b VIOLATION'
      puts "  Message: #{message}"
      puts "  Context: #{context}"
      puts "  Details: #{url}##{url_anchor}"
      puts
    end
    xml_doc.elements.to_a('/processorResult/validationResult').first.attributes['isCompliant'] == 'true'
  end
end
