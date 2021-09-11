# frozen_string_literal: true

class Proc
  class Composition
    attr_reader :input, :callables, :arguments

    def initialize(client:, input:, callables: [], arguments: {})
      @client = client
      @input = input
      @callables = callables
      @arguments = arguments
    end

    def initialize_copy(_)
      @callables = @callables.dup
    end

    # [public] Dispatches this composition to proc using the client.
    #
    def call(input = input_omitted = true, **arguments)
      if block_given?
        arguments[:proc] = yield
      end

      callable = self.class.new(
        client: @client,
        input: input_omitted ? @input : input,
        callables: @callables.dup,
        arguments: @arguments.merge(arguments)
      )

      @client.call("core.exec", Proc::Client.undefined, proc: callable)
    end

    # [public] Dispatches this composition to proc using the client, calling the given block once for each value.
    #
    def each(input = input_omitted = true, **arguments, &block)
      callable = self.class.new(
        client: @client,
        input: input_omitted ? @input : input,
        callables: @callables.dup,
        arguments: @arguments.merge(arguments)
      )

      @client.call("core.exec", Proc::Client.undefined, proc: callable, &block)
    end

    # [public] Creates a new composition based on this one, with a new input and/or arguments.
    #
    def with(input = input_omitted = true, **arguments)
      if block_given?
        arguments[:proc] = yield
      end

      self.class.new(
        client: @client,
        input: input_omitted ? @input : input,
        callables: @callables.dup,
        arguments: @arguments.merge(arguments)
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

    def proc_serialize
      serialized = ["{}"]

      unless Proc::Client.undefined?(@input)
        serialized << [">>", serialized_input]
      end

      serialized + serialized_arguments + @callables.map { |callable| callable.proc_serialize(unwrapped: true) }
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
