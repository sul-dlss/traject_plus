# frozen_string_literal: true
require 'spec_helper'

RSpec.describe TrajectPlus::Extraction do
  describe TrajectPlus::Extraction::TransformPipeline do
    subject(:pipeline) { described_class.new(options) }

    describe '#split' do
      let(:options) { { split: '|' } }

      context 'With two values' do
        let(:data) { ['First half of the string|Second half of the string'] }

        it 'Retuns an array of the values' do
          expect(pipeline.transform(data)).to eq ['First half of the string', 'Second half of the string']
        end
      end
    end

    describe '#replace' do
      let(:options) { { replace: %w[a b] } }
      let(:data) { ['aaa'] }

      it 'Replaces the values' do
        expect(Deprecation).to receive(:warn)
        expect(pipeline.transform(data)).to eq ['bbb']
      end
    end

    describe '#gsub' do
      let(:options) { { gsub: %w[a b] } }
      let(:data) { ['aaa'] }

      it 'Replaces the values' do
        expect(pipeline.transform(data)).to eq ['bbb']
      end
    end

    describe '#strip' do
      let(:options) { { strip: true } }

      context 'Where there is leading and trailing whitespace' do
        let(:data) { ['    This is a string with a lot of whitespace    '] }

        it 'Removes the leading and trailing whitespace' do
          expect(pipeline.transform(data)).to eq ['This is a string with a lot of whitespace']
        end
      end
    end

    describe '#trim' do
      let(:options) { { trim: true } }

      context 'Where there is leading and trailing whitespace' do
        let(:data) { ['    This is a string with a lot of whitespace    '] }

        it 'Removes the leading and trailing whitespace' do
          expect(Deprecation).to receive(:warn)
          expect(pipeline.transform(data)).to eq ['This is a string with a lot of whitespace']
        end
      end
    end

    describe '#append' do
      let(:options) { { append: 'bar' } }
      let(:data) { ['foo'] }

      it 'appends the value' do
        expect(pipeline.transform(data)).to eq ['foobar']
      end
    end

    describe '#default' do
      let(:options) { { default: ['No value'] } }

      it 'uses the original value when present' do
        expect(pipeline.transform(['Some value'])).to eq ['Some value']
      end

      it 'uses the default value when the original is empty' do
        expect(pipeline.transform([])).to eq ['No value']
      end
    end

    describe '#translation_map' do
      let(:options) { { translation_map: 'types' } }

      it 'looks up a value from the translation map' do
        expect(pipeline.transform(['audio'])).to eq ['sound']
      end
    end

    describe 'class-based transform' do
      let(:reversing_class) do
        Class.new do
          def self.call(value, *args)
            value.reverse
          end
        end
      end

      let(:options) { { reversing_class => true } }

      it 'looks up a value from the translation map' do
        expect(pipeline.transform(['123'])).to eq ['321']
      end
    end
  end
end
