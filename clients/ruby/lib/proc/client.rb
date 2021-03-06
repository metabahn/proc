# frozen_string_literal: true

require "core/async"
require "core/global"
require "core/inspect"

require "http"
require "msgpack"

require "proc/composer"

require_relative "msgpack/types/decimal"
MessagePack::DefaultFactory.register_type(0x00, Proc::Msgpack::Types::Decimal)
MessagePack::DefaultFactory.register_type(-1, Time, packer: MessagePack::Time::Packer, unpacker: MessagePack::Time::Unpacker)

require_relative "callable"
require_relative "composition"
require_relative "enumerator"

class Proc
  # [public]
  #
  class Error < StandardError
  end

  # [public] Raised when input or arguments are invalid.
  #
  class Invalid < ::ArgumentError
  end

  # [public] Raised when a proc endpoint does not exist.
  #
  class Undefined < ::NameError
  end

  # [public] Raised when the client is unauthorized.
  #
  class Unauthorized < Error
  end

  # [public] Raised when a call is authorized but is blocked.
  #
  class Forbidden < Error
  end

  # [public] Raised when proc is unavailable due to an unexpected error.
  #
  class Unavailable < Error
  end

  # [public] Raised when the client is being rate limited.
  #
  class Limited < Error
  end

  # [public] Raised when a proc call surpasses the defined limit.
  #
  class Timeout < Error
  end

  # [public] Connection to proc, configured with an authorization.
  #
  class Client < BasicObject
    class << self
      def authorization
        ::ENV.fetch("PROC_AUTH") {
          auth_file_path = ::Pathname.new("~/.proc/auth").expand_path

          if auth_file_path.exist?
            auth_file_path.read
          else
            ""
          end
        }.strip
      end
    end

    include ::Is::Async
    include ::Is::Global
    include ::Is::Inspectable
    inspects :@scheme, :@host, ::Core::Inspect::Inspection.new(name: :@authorization, resolver: :safe_authorization), :@count

    # [public] The configured authorization.
    #
    attr_reader :authorization

    # [public] The configured scheme.
    #
    attr_reader :scheme

    # [public] The configured host.
    #
    attr_reader :host

    # [public] The number of requests this client has performed.
    #
    attr_reader :count

    attr_reader :response

    DEFAULT_HEADERS = {
      "accept" => "application/vnd.proc+msgpack",
      "content-type" => "application/vnd.proc+msgpack"
    }.freeze

    def initialize(authorization = ::Proc::Client.authorization, scheme: "https", host: "proc.run")
      @authorization = authorization
      @scheme = scheme
      @host = host
      @count = 0

      @__base_url = "#{@scheme}://#{host}"
      @__headers = {
        "authorization" => "bearer #{@authorization}"
      }.merge(DEFAULT_HEADERS)
    end

    # [public] Returns a callable context for `proc`.
    #
    def [](proc)
      if ::Kernel.block_given?
        ::Proc::Callable.new(proc, client: self, arguments: {proc: yield})
      else
        ::Proc::Callable.new(proc, client: self)
      end
    end

    # [public] Returns the current rate limit.
    #
    def rate_limit
      refresh_rate_limit
      @rate_limit
    end

    # [public] Returns the current rate limit window.
    #
    def rate_limit_window
      refresh_rate_limit
      @rate_limit_window
    end

    # [public] Returns the time at which the current rate limit will reset.
    #
    def rate_limit_reset
      refresh_rate_limit
      @rate_limit_reset
    end

    private def refresh_rate_limit
      unless defined?(@rate_limit)
        self["core.ping"].call
      end
    end

    # [public] Calls a proc with the given input and arguments.
    #
    # If a block is passed and the proc returns an enumerable, the block will be called with each value.
    #
    def call(proc = nil, input = ::Proc::Composer.undefined, **arguments, &block)
      body = []

      unless ::Proc::Composer.undefined?(input)
        body << [">>", serialize_value(input)]
      end

      arguments.each_pair do |key, value|
        body << ["$$", key.to_s, serialize_value(value)]
      end

      process(proc: proc, body: body, input: input, arguments: arguments, &block)
    end

    private def process(proc:, body:, input:, arguments:, &block)
      status, headers, payload = get_payload(proc: proc, body: body)

      case status
      when 400
        ::Kernel.raise ::Proc::Invalid, extract_error_message(payload)
      when 401
        ::Kernel.raise ::Proc::Unauthorized, extract_error_message(payload)
      when 403
        ::Kernel.raise ::Proc::Forbidden, extract_error_message(payload)
      when 404
        ::Kernel.raise ::Proc::Undefined, extract_error_message(payload)
      when 408
        ::Kernel.raise ::Proc::Timeout, extract_error_message(payload)
      when 413
        ::Kernel.raise ::Proc::Invalid, extract_error_message(payload)
      when 429
        ::Kernel.raise ::Proc::Limited, extract_error_message(payload)
      when 500
        ::Kernel.raise ::Proc::Error, extract_error_message(payload)
      when 508
        ::Kernel.raise ::Proc::Error, extract_error_message(payload)
      else
        result = extract_output(payload)

        if !result.nil?
          if (cursor = headers["x-cursor"])
            enumerator = if cursor.empty?
              ::Proc::Enumerator.new(result)
            else
              ::Proc::Enumerator.new(result) {
                arguments[:cursor] = cursor.to_s
                call(proc, input, **arguments)
              }
            end

            if block
              enumerator.each(&block)
            else
              enumerator
            end
          else
            result
          end
        elsif (error = extract_error_message(payload))
          ::Kernel.raise ::Proc::Error, error
        end
      end
    end

    IGNORE_MISSING = %i[
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

    # [public] Allows callable contexts to be built through method lookups.
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
      elsif input_omitted
        ::Proc::Callable.new(name, client: self, arguments: arguments)
      else
        ::Proc::Callable.new(name, client: self, input: input, arguments: arguments)
      end
    end

    def respond_to_missing?(name, *)
      true
    end

    # [public] Builds a named argument with options.
    #
    def argument(name, **options)
      ::Proc::Composer::Argument.new(name, **options)
    end
    alias_method :arg, :argument

    # [public] Returns a partial representation of the authorization that is safe to include in logs.
    #
    def safe_authorization
      return unless @authorization
      "#{@authorization[0..7]}...#{@authorization[-5..]}"
    end

    private def build_uri(proc)
      ::File.join(@__base_url, proc.to_s.split(".").join("/"))
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

    private def get_payload(proc:, body:)
      await {
        @count += 1

        response = ::HTTP.headers(@__headers).post(build_uri(proc), body: ::MessagePack.pack(body))

        update_rate_limit(response)
        @response = response

        [response.status, response.headers, ::MessagePack.unpack(response.to_s)]
      }
    rescue
      ::Kernel.raise ::Proc::Unavailable
    end

    private def update_rate_limit(response)
      split_limit = response.headers["x-rate-limit"].to_s.split(";window=")

      @rate_limit = split_limit[0].to_i

      @rate_limit_window = case split_limit[1]
      when "60"
        :minute
      when "1"
        :second
      end

      @rate_limit_reset = if (reset = response.headers["x-rate-limit-reset"])
        ::Time.at(reset.to_s.to_i)
      end
    end

    private def extract_output(payload)
      payload.each do |tuple|
        case tuple[0]
        when "<<"
          return tuple[1]
        end
      end

      nil
    end

    private def extract_error(payload)
      payload.each do |tuple|
        case tuple[0]
        when "!!"
          return tuple[1]
        end
      end

      nil
    end

    private def extract_error_message(payload)
      extract_error(payload)&.dig("message")
    end
  end
end
