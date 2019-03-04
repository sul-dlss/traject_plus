# frozen_string_literal: true

require 'jsonpath'

module TrajectPlus
  module Macros
    # Macros for extracting values from JSON documents
    module JSON
      # @param path [String] the jsonpath query expression
      # @param options [Hash] other options, may include :trim
      def extract_json(path, options = {})
        lambda do |json, accumulator, _context|
          result = Array(JsonPath.on(json, path))
          result = TrajectPlus::Extraction.apply_extraction_options(result, options)
          unless options.empty?
            Deprecation.warn(self, "passing options to extract_json is deprecated and will be removed in the next major release. Use the Traject 3 pipeline instead")
          end
          accumulator.concat(result)
        end
      end
    end
  end
end
