module TrajectPlus
  module Indexer
    class ToFieldStep < Traject::Indexer::ToFieldStep
      include Traject::Macros::Transformation

      def initialize(fieldname, procs, block, source_location, single: false)
        if single
          procs += [first_only]
          Deprecation.warn(self, "passing single to to_field is deprecated. use 'first_only' lambda instead")
        end
        super(fieldname, procs, block, source_location)
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

      def self.add_accumulator_to_context!(field, field_name, accumulator, context)
        accumulator.compact! unless context.settings[ALLOW_NIL_VALUES]
        return if accumulator.empty? and not (context.settings[ALLOW_EMPTY_FIELDS])

        # field_name can actually be an array of field names
        Array(field_name).each do |a_field_name|
          context.output_hash[a_field_name] ||= []

          existing_accumulator = context.output_hash[a_field_name].concat(accumulator)
          existing_accumulator.uniq! unless context.settings[ALLOW_DUPLICATE_VALUES]
        end
      end

      # disable to_field_step? so we can implement our own version of add_accumulator_to_context
      def to_field_step?
        false
      end

      def execute(context)
        accumulator = []
        source_record = context.source_record

        if procs
          procs.call(context.source_record, accumulator, context)
        else
          accumulator << context.source_record
        end

        accumulator.map do |record|
          new_context = Traject::Indexer::Context.new(source_record: record, settings: indexer.settings)
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

        # This overrides the superclass so that we can call the class method instead
        def add_accumulator_to_context!(accumulator, context)
          self.class.add_accumulator_to_context!(self, field_name, accumulator, context)
        end
      end
    end
  end
end
