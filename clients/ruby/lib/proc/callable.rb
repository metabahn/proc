# frozen_string_literal: true

class Proc
  class Callable < BasicObject
    attr_reader :proc, :input, :arguments

    def initialize(proc, client:, input: ::Proc::Client.undefined, arguments: {})
      @proc = proc.to_s
      @client = client
      @input = input
      @arguments = arguments
    end

    def initialize_copy(_)
      @input = input.dup
      @arguments = arguments.dup
    end

    # [public] Dispatches this callable context to proc using the client.
    #
    # If a block is passed, it will be called to prior to dispatch and its result passed as a nested context.
    #
    def call(input = input_omitted = true, **arguments)
      if ::Kernel.block_given?
        arguments[:proc] = yield
      end

      callable = ::Proc::Callable.new(
        @proc,
        client: @client,
        input: input_omitted ? @input : input,
        arguments: @arguments.merge(arguments)
      )

      @client.call(@proc, callable.input, **callable.arguments)
    end

    # [public] Dispatches this callable context to proc using the client, calling the given block once for each value.
    #
    def each(input = input_omitted = true, **arguments, &block)
      callable = ::Proc::Callable.new(
        @proc,
        client: @client,
        input: input_omitted ? @input : input,
        arguments: @arguments.merge(arguments)
      )

      @client.call(@proc, callable.input, **callable.arguments, &block)
    end

    # [public] Creates a new callable context based on this one, with a new input and/or arguments.
    #
    def with(input = input_omitted = true, **arguments)
      if ::Kernel.block_given?
        arguments[:proc] = yield
      end

      ::Proc::Callable.new(
        @proc,
        client: @client,
        input: input_omitted ? @input : input,
        arguments: @arguments.merge(arguments)
      )
    end

    # [public] Returns a composition built from this callable context and one or more other callables.
    #
    def compose(*others)
      composed = ::Proc::Composition.new(client: @client, input: @input)
      composed << self
      others.each { |other| composed << other }
      composed
    end

    # [public] Returns a composition built from this callable context and another callable.
    #
    def >>(other)
      composed = ::Proc::Composition.new(client: @client, input: @input)
      composed << self
      composed << other
      composed
    end

    def proc_serialize(unwrapped: false)
      serialized = ["()", @proc]

      unless ::Proc::Client.undefined?(@input)
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

      ::Proc::Callable.new(
        [@proc, proc].join("."),
        client: @client,
        input: @input,
        arguments: arguments
      )
    end

    IGNORE_MISSING = %i[to_hash].freeze

    # [public] Allows nested callable contexts to be built through method lookups.
    #
    def method_missing(name, input = input_omitted = true, **arguments)
      if IGNORE_MISSING.include?(name)
        super
      else
        if ::Kernel.block_given?
          arguments[:proc] = yield
        end

        ::Proc::Callable.new(
          [@proc, name].join("."),
          client: @client,
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
      if value.respond_to?(:proc_serialize)
        value.proc_serialize
      elsif value.is_a?(::Symbol)
        ["@@", value.to_s, {}]
      else
        ["%%", value]
      end
    end
  end
end
