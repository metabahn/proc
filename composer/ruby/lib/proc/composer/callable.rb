# frozen_string_literal: true

require "core/inspect"

class Proc
  module Composer
    class Callable < BasicObject
      include ::Is::Inspectable
      inspects :@proc, :@input, :@arguments

      attr_reader :proc, :input, :arguments

      def initialize(proc, input: ::Proc::Composer.undefined, arguments: {})
        @proc = proc.to_s
        @input = input
        @arguments = arguments
      end

      def initialize_copy(_)
        @input = input.dup
        @arguments = arguments.dup
      end

      # [public] Creates a new callable context based on this one, with a new input and/or arguments.
      #
      def with(input = input_omitted = true, **arguments)
        if ::Kernel.block_given?
          arguments[:proc] = yield
        end

        build_callable(input: input_omitted ? @input : input, arguments: @arguments.merge(arguments))
      end

      # [public] Returns a composition built from this callable context and one or more other callables.
      #
      def compose(*others)
        composed = build_composition(input: @input)
        composed << self
        others.each { |other| composed << other }
        composed
      end

      # [public] Returns a composition built from this callable context and another callable.
      #
      def >>(other)
        composed = build_composition(input: @input)
        composed << self
        composed << other
        composed
      end
      alias_method :|, :>>

      def serialize(unwrapped: false)
        serialized = ["()", @proc]

        unless ::Proc::Composer.undefined?(@input)
          serialized << [">>", serialized_input]
        end

        serialized.concat(serialized_arguments)

        if unwrapped
          serialized
        else
          ["{}", serialized]
        end
      end

      def serialized_input
        serialize_value(@input)
      end

      def serialized_arguments
        @arguments.map { |key, value|
          ["$$", key.to_s, serialize_value(value)]
        }
      end

      # [public] Returns a callable context for `proc`, nested within this callable context.
      #
      def [](proc)
        arguments = if ::Kernel.block_given?
          duped = @arguments.dup
          duped[:proc] = yield
          duped
        else
          @arguments
        end

        build_callable(proc: [@proc, proc].join("."), input: @input, arguments: arguments)
      end

      IGNORE_MISSING = %i[
        to_hash
      ].freeze

      KERNEL_DELEGATE = %i[
        class
        instance_variables
        instance_variable_get
        instance_variable_set
        object_id
        public_send
        respond_to?
      ].freeze

      # [public] Allows nested callable contexts to be built through method lookups.
      #
      def method_missing(name, input = input_omitted = true, *parameters, **arguments, &block)
        if IGNORE_MISSING.include?(name)
          super
        elsif KERNEL_DELEGATE.include?(name)
          if input_omitted
            ::Kernel.instance_method(name).bind_call(self, *parameters, **arguments, &block)
          else
            ::Kernel.instance_method(name).bind_call(self, input, *parameters, **arguments, &block)
          end
        else
          if block
            arguments[:proc] = yield
          end

          build_callable(
            proc: [@proc, name].join("."),
            input: input_omitted ? @input : input,
            arguments: @arguments.merge(arguments)
          )
        end
      end

      def respond_to_missing?(name, *)
        if IGNORE_MISSING.include?(name)
          super
        else
          true
        end
      end

      private def serialize_value(value)
        case value
        when ::Symbol
          ["@@", value.to_s, {}]
        else
          if value.respond_to?(:serialize)
            value.serialize
          else
            ["%%", value]
          end
        end
      end

      private def build_callable(input:, arguments:, proc: @proc)
        ::Proc::Composer::Callable.new(proc, input: input, arguments: arguments)
      end

      private def build_composition(input:)
        ::Proc::Composer::Composition.new(input: input)
      end
    end
  end
end
