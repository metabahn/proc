# frozen_string_literal: true

class Proc
  class Argument
    def initialize(name, **options)
      @name = name
      @options = options
    end

    def proc_serialize
      ["@@", @name.to_s, serialized_options]
    end

    def serialized_options
      @options.each_pair.each_with_object({}) { |(key, value), hash|
        hash[key.to_s] = serialize_value(value)
      }
    end

    private def serialize_value(value)
      if value.respond_to?(:proc_serialize)
        value.proc_serialize
      else
        ["%%", value]
      end
    end
  end
end
