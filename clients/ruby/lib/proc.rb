# frozen_string_literal: true

require_relative "proc/client"
require_relative "proc/version"

class Proc
  class << self
    # [public] Connect a client with an authorization.
    #
    def connect(authorization = Proc::Client.authorization, client: Proc::Client, **options)
      client.new(authorization, **options)
    end
  end
end
