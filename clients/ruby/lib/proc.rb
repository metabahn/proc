# frozen_string_literal: true

require_relative "proc/client"
require_relative "proc/version"

class Proc
  class << self
    # [public] Connect a client with an authorization.
    #
    def connect(authorization, **options)
      Client.new(authorization, **options)
    end

    def undefined
      @_undefined ||= ::Object.new
    end

    def undefined?(value)
      value == undefined
    end
  end
end
