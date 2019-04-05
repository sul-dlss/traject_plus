# frozen_string_literal: true

module TrajectPlus
  module Macros
    # Macros for extracting FGDC values from Nokogiri documents
    module FGDC
      NS = { fgdc: 'http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd' }.freeze

      def self.extended(mod)
        mod.extended Traject::Macros::NokogiriMacros
      end

      # @param xpath [String] the xpath query expression
      def extract_fgdc(xpath)
        extract_xpath(xpath, ns: NS)
      end
    end
  end
end
