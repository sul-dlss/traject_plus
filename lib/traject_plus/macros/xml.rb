# frozen_string_literal: true

module TrajectPlus
  module Macros
    # Macros for extracting MODS values from Nokogiri documents
    module Xml
      # @param xpath [String] the xpath query expression
      # @param namespaces [Hash<String,String>] The namespaces for the xpath query
      # @param options [Hash] other options, may include :trim
      def extract_xml(xpath, namespaces, options = {})
        lambda do |xml, accumulator, _context|
          result = xml.xpath(xpath, namespaces).map(&:text)
          unless options.empty?
            Deprecation.warn(self, "passing options to extract_xml is deprecated and will be removed in the next major release. Use the Traject 3 pipeline instead")
          end
          result = TrajectPlus::Extraction.apply_extraction_options(result, options)
          accumulator.concat(result)
        end
      end
    end
  end
end
