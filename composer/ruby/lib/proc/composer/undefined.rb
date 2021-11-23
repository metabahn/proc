# frozen_string_literal: true

class Proc
  module Composer
    # [public]
    #
    class Undefined
      def inspect
        "(undefined)".inspect
      end
    end
  end
end
