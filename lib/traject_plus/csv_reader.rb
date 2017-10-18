# frozen_string_literal: true

require 'csv'

# Reads in CSV records for traject
module TrajectPlus
  class CsvReader
    # @param input_stream [File]
    # @param settings [Traject::Indexer::Settings]
    def initialize(input_stream, settings)
      @settings = Traject::Indexer::Settings.new settings
      @input_stream = input_stream
      @csv = CSV.parse(input_stream, headers: true)
    end

    def each(*args, &block)
      csv.each(*args, &block)
    end

    attr_reader :csv
  end
end
