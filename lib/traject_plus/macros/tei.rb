# frozen_string_literal: true
module TrajectPlus
  module Macros
    # Macros for extracting TEI values from Nokogiri documents
    module Tei
      NS = { tei: 'http://www.tei-c.org/ns/1.0' }.freeze

      def self.extended(mod)
        mod.extended Traject::Macros::NokogiriMacros
      end

      # @param xpath [String] the xpath query expression
      def extract_tei(xpath)
        extract_xpath(xpath, ns: NS)
      end
    end
  end
end
