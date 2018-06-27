# frozen_string_literal: true
module TrajectPlus
  module Macros
    # construct a structured hash using values extracted using traject
    def transform_values(context, hash)
      hash.transform_values do |lambdas|
        accumulator = []
        Array(lambdas).each do |lambda|
          lambda.call(context.source_record, accumulator, context)
        end
        accumulator
      end
    end

    # try a bunch of macros and short-circuit after one returns values
    def first(*macros)
      lambda do |record, accumulator, context|
        macros.lazy.map do |block|
          block.call(record, accumulator, context)
        end.reject(&:blank?).first
      end
    end

    def accumulate(&block)
      lambda do |record, accumulator, context|
        Array(block.call(record, context)).each do |v|
          accumulator << v if v.present?
        end
      end
    end

    # only accumulate values if a condition is met
    def conditional(condition, block)
      lambda do |record, accumulator, context|
        if condition.call(record, context)
          block.call(record, accumulator, context)
        end
      end
    end

    def from_settings(field)
      accumulate do |record, context|
        context.settings.fetch(field)
      end
    end

    def copy(field)
      accumulate do |_record, context|
        Array(context.output_hash[field])
      end
    end

    def transform(options = {})
      lambda do |record, accumulator, context|
        results = TrajectPlus::Extraction.apply_extraction_options(accumulator, options)
        accumulator.replace(results)
      end
    end

    # apply the same mapping to multiple fields
    def to_fields(fields, mapping_method)
      fields.each { |field| to_field field, mapping_method }
    end

    def to_field(field_name, aLambda = nil, extract: nil, transform: nil, **namedArgs, &block)
      @index_steps << TrajectPlus::Indexer::ToFieldStep.new(field_name, extract || aLambda, transform || block, Traject::Util.extract_caller_location(caller.first), **namedArgs)
    end

    def compose(fieldname = nil, aLambda = nil, method: :merge, extract: nil, transform: nil, &block)
      if fieldname.is_a? Proc
        aLambda ||= fieldname
        fieldname = nil
      end

      indexer = self.class.new(settings)
      indexer.instance_eval(&block)

      @index_steps << TrajectPlus::Indexer::ComposeStep.new(fieldname, extract || aLambda, transform, Traject::Util.extract_caller_location(caller.first), indexer, method: method)
    end
  end
end
