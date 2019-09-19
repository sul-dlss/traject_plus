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

  describe '#transform_values' do
    let(:doc) { Nokogiri::XML('<xml><foo> bar </foo></xml>') }
    context 'with lambdas with 2 and 3 arity' do
      it 'runs both' do
        indexer.extend TrajectPlus::Macros::Xml
        indexer.instance_eval do
          to_field 'some_field' do |_record, accumulator, context|
            accumulator << transform_values(
              context,
              'wr_id' => [extract_xml('//foo', {}), strip]
            )
          end
        end

        expect(indexer.map_record(doc)).to eq('some_field' => [{ 'wr_id' => ['bar'] }])
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

    it 'provides position and position_in_input information in the context' do
      indexer.instance_eval do
        compose 'field_name', ->(record, accumulator, _context) { accumulator << 'test' << 'test2' } do
          to_field 'position', ->(_record, accumulator, context) { accumulator << context.position }
        end
      end

      expect(indexer.map_record(nil)).to include 'field_name' => [{ 'position' => [0] }, { 'position' => [1] }]
    end
  end

  describe '#transform' do
    it 'runs values through a common transform pipeline' do
      expect(Deprecation).to receive(:warn).twice
      indexer.instance_eval do
        to_field 'some_field', extract: accumulate { |record, *_| record[:value] }, transform: transform(split: '/', prepend: '-', upcase: true)
      end

      expect(indexer.map_record(value: 'a/b/c')).to include 'some_field' => ['-A', '-B', '-C']
    end
  end

  describe '#to_field' do
    context 'with extract and transform fields' do
      it 'runs both extract and transform' do
        expect(Deprecation).to receive(:warn).twice
        indexer.instance_eval do
          to_field 'some_field', extract: accumulate { |record, *_| record[:value] }, transform: transform(split: '/', prepend: '-', upcase: true)
        end

        expect(indexer.map_record(value: 'a/b/c')).to include 'some_field' => ['-A', '-B', '-C']
      end
    end

    context 'with a list of procs' do
      it 'runs all procs' do
        indexer.instance_eval do
          to_field 'some_field', accumulate { |record, *_| record[:value] }, split('/'), prepend('-'), transform(&:upcase), append('*')
        end

        expect(indexer.map_record(value: 'a/b/c')).to include 'some_field' => ['-A*', '-B*', '-C*']
      end
    end

    context 'with single: true' do
      it 'casts to a scalar' do
        indexer.instance_eval do
          to_field 'some_field', accumulate { |record, *_| record[:value] }, single: true
        end

        expect(indexer.map_record(value: 'a/b/c')).to include 'some_field' => 'a/b/c'
      end
    end
  end
end
