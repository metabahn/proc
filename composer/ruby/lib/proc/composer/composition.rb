# frozen_string_literal: true

class Proc
  module Composer
    class Composition
      attr_reader :input, :callables, :arguments

      def initialize(input:, callables: [], arguments: {})
        @input = input
        @callables = callables
        @arguments = arguments
      end

      def initialize_copy(_)
        @callables = @callables.dup
      end

      # [public] Creates a new composition based on this one, with a new input and/or arguments.
      #
      def with(input = input_omitted = true, **arguments)
        if block_given?
          arguments[:proc] = yield
        end

        build_composition(
          input: input_omitted ? @input : input,
          arguments: @arguments.merge(arguments),
          callables: @callables.dup
        )
      end

      # [public] Returns a composition from this composition and one or more other callables.
      #
      def compose(*others)
        composed = dup
        others.each { |other| composed << other }
        composed
      end

      # [public] Returns a composition built from this composition and another callable.
      #
      def >>(other)
        composed = dup
        composed << other
        composed
      end

      def <<(callable)
        case callable
        when Composition
          merge(callable)
        when Callable
          @callables << callable
        end
      end

      def serialize
        serialized = ["{}"]

        unless Proc::Composer.undefined?(@input)
          serialized << [">>", serialized_input]
        end

        serialized + serialized_arguments + @callables.map { |callable| callable.serialize(unwrapped: true) }
      end

      def serialized_input
        serialize_value(@input)
      end

      def serialized_arguments
        @arguments.map { |key, value|
          ["$$", key.to_s, serialize_value(value)]
        }
      end

      def merge(composition)
        raise ArgumentError, "expected a composition" unless composition.is_a?(self.class)

        @callables.concat(composition.callables)
        @arguments.merge!(composition.arguments)
      end

      private def serialize_value(value)
        case value
        when Symbol
          ["@@", value.to_s, {}]
        when Argument, Callable, Composition
          value.serialize
        else
          ["%%", value]
        end
      end

      private def build_composition(callables:, input:, arguments:)
        self.class.new(input: input, callables: callables, arguments: arguments)
      end
    end
  end
end
