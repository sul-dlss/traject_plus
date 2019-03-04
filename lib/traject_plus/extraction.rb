# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'deprecation'

module TrajectPlus
  # @deprecated because Traject 3 can do this for us.
  module Extraction
    def self.apply_extraction_options(result, options = {})
      TransformPipeline.new(options).transform(result)
    end

    # Pipeline for transforming extracted values into normalized values
    class TransformPipeline
      extend Deprecation

      attr_reader :options

      def initialize(options)
        @options = options
      end

      def transform(values)
        options.inject(values) do |memo, (step, params)|
          if step.respond_to? :call
            memo.flat_map { |v| step.call(v, params) }
          else
            public_send(step, memo, params)
          end
        end
      end

      # Examples:
      #
      # to_field 'x', split: '/' #  'a / b / c' => 'a', 'b', 'c'
      # to_field 'x', concat: '123' # 'abc' to 'abc123'
      # to_field 'x', prepend: '321' # 'abc' to '321abc'
      # to_field 'x', gsub: ['a', 'b'] # 'abc' to 'bbc'
      # to_field 'x', gsub: [/[abc]/, 'b'] # 'abc' to 'bbb'
      # to_field 'x', encode: 'UTF-8' # 'abc' to 'abc'
      # to_field 'x', insert: [1, 'x'] # 'abc' to 'axbc'
      ['split', 'concat', 'prepend', 'gsub', 'encode', 'insert'].each do |method|
        define_method(method) do |values, args|
          values.flat_map do |v|
            # Cannot prepend to frozen string; use #dup to effectively unfreeze
            v.dup.public_send(method, *args)
          end
        end
      end

      # to_field 'x', strip: true # ' abc ' to 'abc'
      # to_field 'x', upcase: true # 'abc' to 'ABC'
      # to_field 'x', downcase: true # 'ABC' to 'abc'
      # to_field 'x', capitalize: true # 'abc' to 'Abc'
      ['strip', 'upcase', 'downcase', 'capitalize'].each do |method|
        define_method(method) do |values, *args|
          values.map(&(method.to_sym))
        end
      end

      # to_field 'x', append: '321' # 'abc' to 'abc321'
      def append(values, append_string)
        values.flat_map do |v|
          "#{v}#{append_string}"
        end
      end

      # to_field 'x', match: [/([aeiou])/, 1] # 'abc' => 'a'
      def match(values, match, index)
        values.flat_map do |v|
          v.match(match) do |m|
            m[index]
          end
        end
      end

      # to_field 'x', format: '-> %s <-' # 'abc' to '-> abc <-'
      def format(values, insert_string)
        values.flat_map do |v|
          insert_string % v
        end
      end

      # to_field 'x', select: lambda { |x| x =~ /a/} # ['a', 'b'] => ['a']
      def select(values, block)
        values.select(&block)
      end

      # to_field 'x', reject: lambda { |x| x =~ /a/} # ['a', 'b'] => ['b']
      def reject(values, block)
        values.reject(&block)
      end

      # to_field 'x', min: 1 # ['a', 'b'] => ['a']
      def min(values, count, block = nil)
        if block.present?
          values.min(count)
        else
          values.min(count, &block)
        end
      end

      # to_field 'x', max: 1 # ['a', 'b'] => ['b']
      def max(values, count, block = nil)
        if block.present?
          values.max(count)
        else
          values.max(count, &block)
        end
      end

      # Using a named Traject translation map:
      # to_field 'x', translation_map: 'types' # 'x' => 'mapped x',
      def translation_map(values, maps)
        translation_map = Traject::TranslationMap.new(*Array(maps))
        translation_map.translate_array Array(values)
      end

      # to_field 'x', default: 'y' # nil => 'y'
      def default(values, default_value)
        if values.present?
          values
        else
          default_value
        end
      end

      alias replace gsub
      deprecation_deprecate replace: "use gsub instead"
      alias trim strip
      deprecation_deprecate trim: "use strip instead"
    end
  end
end
