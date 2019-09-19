module TrajectPlus
  module Indexer
    class ToFieldStep < Traject::Indexer::ToFieldStep
      # @param single [Bool] if true, this outputs a scalar value (rather than an Array)
      #                      by default Traject only outputs arrays.
      def initialize(fieldname, procs, block, source_location, single: false)
        super(fieldname, procs, block, source_location)

        @single = single
      end

      def single?
        !!@single
      end

      # disable to_field_step? so we can implement our own version of add_accumulator_to_context
      def to_field_step?
        false
      end

      def add_accumulator_to_context!(accumulator, context)
        self.class.add_accumulator_to_context!(self, field_name, accumulator, context)
      end

      def self.add_accumulator_to_context!(field, field_name, accumulator, context)
        accumulator.compact! unless context.settings[ALLOW_NIL_VALUES]
        return if accumulator.empty? and not (context.settings[ALLOW_EMPTY_FIELDS])

        # field_name can actually be an array of field names
        Array(field_name).each do |a_field_name|
          if field.single?
            context.output_hash[a_field_name] = accumulator.first if accumulator.length > 0
          else
            context.output_hash[a_field_name] ||= []

            existing_accumulator = context.output_hash[a_field_name].concat(accumulator)
            existing_accumulator.uniq! unless context.settings[ALLOW_DUPLICATE_VALUES]
          end
        end
      end
    end

    class ComposeStep < ToFieldStep
      attr_reader :indexer

      def initialize(fieldname, procs, block, source_location, indexer)
        @indexer             = indexer
        @field_name          = fieldname
        @procs               = procs
        @block               = block
        @source_location     = source_location
      end

      def execute(context)
        accumulator = []
        source_record = context.source_record

        if procs
          procs.call(context.source_record, accumulator, context)
        else
          accumulator << context.source_record
        end

        accumulator.each_with_index.map do |record, index|
          new_context = Traject::Indexer::Context.new(
            source_record: record,
            settings: indexer.settings,
            position: index,
            position_in_input: index
          )
          new_context.clipboard[:parent] = context
          indexer.map_to_context!(new_context)
          result = new_context.output_hash

          if field_name
            self.class.add_accumulator_to_context! self, field_name, [result], context
          else
            result.each do |k, v|
              self.class.add_accumulator_to_context! self, k, Array(v), context
            end
          end
        end
      end
    end
  end
end
