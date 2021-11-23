# frozen_string_literal: true

class Proc
  class Composition < Composer::Composition
    inspects :@client

    def initialize(client:, **kwargs)
      @client = client

      super(**kwargs)
    end

    # [public] Dispatches this composition to proc using the client.
    #
    def call(input = input_omitted = true, **arguments)
      if block_given?
        arguments[:proc] = yield
      end

      callable = build_composition(
        input: input_omitted ? @input : input,
        arguments: @arguments.merge(arguments),
        callables: @callables.dup
      )

      @client.call("core.exec", Proc::Composer.undefined, proc: callable)
    end

    # [public] Dispatches this composition to proc using the client, calling the given block once for each value.
    #
    def each(input = input_omitted = true, **arguments, &block)
      callable = build_composition(
        client: @client,
        input: input_omitted ? @input : input,
        arguments: @arguments.merge(arguments)
      )

      @client.call("core.exec", Proc::Composer.undefined, proc: callable, &block)
    end

    private def build_composition(callables:, input:, arguments:)
      self.class.new(client: @client, input: input, callables: callables, arguments: arguments)
    end
  end
end
