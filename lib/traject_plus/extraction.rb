# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
module TrajectPlus
  module Extraction
    def self.apply_extraction_options(result, options = {})
      TransformPipeline.new(options).transform(result)
    end

    # Pipeline for transforming extracted values into normalized values
    class TransformPipeline
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def transform(values)
        options.inject(values) { |memo, (step, params)| public_send(step, memo, params) }
      end

      ['split', 'concat', 'prepend', 'gsub', 'encode', 'insert'].each do |method|
        define_method(method) do |values, *args|
          values.flat_map do |v|
            v.public_send(method, *args)
          end
        end
      end

      ['strip', 'upcase', 'downcase', 'capitalize'].each do |method|
        define_method(method) do |values, *args|
          values.map(&(method.to_sym))
        end
      end

      def match(values, match, index)
        values.flat_map do |v|
          v.match(match) do |m|
            m[index]
          end
        end
      end

      def format(values, insert_string)
        values.flat_map do |v|
          insert_string % v
        end
      end

      def translation_map(values, maps)
        translation_map = Traject::TranslationMap.new(*Array(maps))
        translation_map.translate_array Array(values)
      end

      def default(values, default_value)
        if values.present?
          values
        else
          default_value
        end
      end
    end
  end
end
