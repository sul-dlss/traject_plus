# frozen_string_literal: true

module TrajectPlus
  module Macros
    # Macros for extracting FGDC values from Nokogiri documents
    module FGDC
      NS = { fgdc: 'http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd' }.freeze

      # @param xpath [String] the xpath query expression
      def extract_fgdc(xpath, options = {})
        extract_xml(xpath, NS, options)
      end
    end
  end
end
