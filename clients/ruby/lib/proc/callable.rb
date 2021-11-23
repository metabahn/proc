# frozen_string_literal: true

class Proc
  class Callable < Composer::Callable
    inspects :@client

    def initialize(proc, client:, **kwargs)
      @client = client

      super(proc, **kwargs)
    end

    # [public] Dispatches this callable context to proc using the client.
    #
    # If a block is passed, it will be called to prior to dispatch and its result passed as a nested context.
    #
    def call(input = input_omitted = true, **arguments)
      if ::Kernel.block_given?
        arguments[:proc] = yield
      end

      callable = build_callable(input: input_omitted ? @input : input, arguments: @arguments.merge(arguments))

      @client.call(@proc, callable.input, **callable.arguments)
    end

    # [public] Dispatches this callable context to proc using the client, calling the given block once for each value.
    #
    def each(input = input_omitted = true, **arguments, &block)
      callable = build_callable(input: input_omitted ? @input : input, arguments: @arguments.merge(arguments))

      @client.call(@proc, callable.input, **callable.arguments, &block)
    end

    private def build_callable(input:, arguments:, proc: @proc)
      ::Proc::Callable.new(proc, client: @client, input: input, arguments: arguments)
    end

    private def build_composition(input:)
      ::Proc::Composition.new(client: @client, input: input)
    end
  end
end
