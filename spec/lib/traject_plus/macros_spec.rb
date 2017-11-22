# frozen_string_literal: true
require 'spec_helper'

RSpec.describe TrajectPlus::Macros do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
      end
    end
  end

  describe '#compose' do
    it 'adds composed fields to the original record' do
      indexer.instance_eval do
        compose ->(record, accumulator, _context) { accumulator << 'test' } do
          to_field 'composed', ->(record, accumulator, _context) { accumulator << record }
        end
      end

      expect(indexer.map_record(nil)).to include 'composed' => ['test']
    end

    it 'adds composed fields as a key the original record' do
      indexer.instance_eval do
        compose 'field_name', ->(record, accumulator, _context) { accumulator << 'test' } do
          to_field 'composed', ->(record, accumulator, _context) { accumulator << record }
        end
      end

      expect(indexer.map_record(nil)).to include 'field_name' => [{ 'composed' => ['test'] }]
    end
  end
end
