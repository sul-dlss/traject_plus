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
          to_field 'second', literal('another')
        end
      end

      expect(indexer.map_record(nil)).to include 'field_name' => [{ 'composed' => ['test'], 'second' => ['another'] }]
    end

    it 'provides access to the original context through the clipboard' do
      indexer.instance_eval do
        each_record do |record, context|
          context.clipboard[:value] = 'Yes!'
        end

        compose 'field_name', ->(record, accumulator, _context) { accumulator << 'test' } do
          to_field 'parent_context_value', ->(_record, accumulator, context) { accumulator << context.clipboard[:parent].clipboard[:value] }
        end
      end

      expect(indexer.map_record(nil)).to include 'field_name' => [{ 'parent_context_value' => ['Yes!']}]

    end
  end

  describe '#transform' do
    it 'runs values through a common transform pipeline' do
      indexer.instance_eval do
        to_field 'some_field', extract: accumulate { |record, *_| record[:value] }, transform: transform(split: '/', prepend: '-', upcase: true)
      end

      expect(indexer.map_record(value: 'a/b/c')).to include 'some_field' => ['-A', '-B', '-C']
    end
  end
end
