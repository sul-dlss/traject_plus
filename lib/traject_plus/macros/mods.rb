# frozen_string_literal: true

module TrajectPlus
  module Macros
    # Macros for extracting MODS values from Nokogiri documents
    module Mods
      NS = { mods: 'http://www.loc.gov/mods/v3',
             rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
             dc: 'http://purl.org/dc/elements/1.1/',
             xlink: 'http://www.w3.org/1999/xlink' }.freeze

      include Traject::Macros::NokogiriMacros

      # @param xpath [String] the xpath query expression
      def extract_mods(xpath)
        extract_xpath(xpath, ns: NS)
      end
    end
  end
end
