# frozen_string_literal: true

require_relative "../client"

class Proc
  module Clients
    # [public] Returns an ast that can be passed to `core.exec`.
    #
    class AST < Client
      private def process(proc:, body:, **)
        case proc
        when "core.exec"
          body.dig(0, 2)
        else
          ["{}", ["()", proc].concat(body)]
        end
      end
    end
  end
end
