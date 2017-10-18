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
        macros.lazy.map do |lambda|
          lambda.call(record, accumulator, context)
        end.reject(&:blank?).first
      end
    end

    # only accumulate values if a condition is met
    def conditional(condition, lambda)
      lambda do |record, accumulator, context|
        if condition.call(record, context)
          lambda.call(record, accumulator, context)
        end
      end
    end

    def from_settings(field)
      lambda { |_record, accumulator, context|
        accumulator << context.settings.fetch(field)
      }
    end
  end
end
