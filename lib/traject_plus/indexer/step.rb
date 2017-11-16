module TrajectPlus
  module Indexer
    class ToFieldStep < Traject::Indexer::ToFieldStep
      def initialize(fieldname, lambda, block, source_location, single: false)
        super(fieldname, lambda, block, source_location)

        @single = single
      end

      def single?
        !!@single
      end

      # disable to_field_step? so we can implement our own version of add_accumulator_to_context
      def to_field_step?
        false
      end

      def execute(context)
        accumulator = super

        add_accumulator_to_context!(accumulator, context)
      end

      def add_accumulator_to_context!(accumulator, context)
        self.class.add_accumulator_to_context!(self, field_name, accumulator, context)
      end

      def self.add_accumulator_to_context!(field, field_name, accumulator, context)
        accumulator.compact! unless context.settings[Traject::Indexer::ALLOW_NIL_VALUES]
        return if accumulator.empty? and not (context.settings[Traject::Indexer::ALLOW_EMPTY_FIELDS])

        if field.single?
          context.output_hash[field_name] = accumulator.first if accumulator.length > 0
        else
          context.output_hash[field_name] ||= []

          existing_accumulator = context.output_hash[field_name].concat(accumulator)
          existing_accumulator.uniq! unless context.settings[Traject::Indexer::ALLOW_DUPLICATE_VALUES]
        end
      end
    end

    class ComposeStep < ToFieldStep
      attr_reader :indexer

      def initialize(indexer, lambda, block, source_location)
        @indexer             = indexer
        self.field_name      = '__placeholder__'
        self.lambda          = lambda
        self.block           = block
        self.source_location = source_location

        validate!
      end

      def execute(context)
        accumulator = []
        lambda.call(context.source_record, accumulator, context)

        accumulator.map do |record|
          indexer.map_record(record).each do |k, v|
            self.class.add_accumulator_to_context! self, k, Array(v), context
          end
        end
      end
    end
  end
end
