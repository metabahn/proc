# frozen_string_literal: true

require_relative "../client"

class Proc
  module Clients
    # [public] Returns an ast that can be passed to `core.exec`.
    #
    class AST < Client
      private def process(proc:, body:, **)
        unless proc == "core.exec"
          body = [["$$", "proc", ["{}", ["()", proc].concat(body)]]]
        end

        body
      end
    end
  end
end
