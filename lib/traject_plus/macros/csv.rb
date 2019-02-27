# frozen_string_literal: true

module TrajectPlus
  module Macros
    # Macros for extracting values from CSV rows
    module Csv
      # Retrieve the value of the column with the given header or index.
      # @param header_or_index [String] the field header or index to accumulate
      def column(header_or_index, options = {})
        lambda do |row, accumulator, _context|
          return if row[header_or_index].to_s.empty?
          result = Array(row[header_or_index].to_s)
          unless options.empty?
            Deprecation.warn(self, "passing options to column is deprecated and will be removed in the next major release. Use the Traject 3 pipeline instead")
          end
          result = TrajectPlus::Extraction.apply_extraction_options(result, options)
          accumulator.concat(result)
        end
      end
    end
  end
end
