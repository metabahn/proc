# frozen_string_literal: true

require_relative "composer/argument"
require_relative "composer/callable"
require_relative "composer/composition"
require_relative "composer/undefined"
require_relative "composer/version"

class Proc
  module Composer
    def self.undefined
      @_undefined ||= Proc::Composer::Undefined.new
    end

    def self.undefined?(value)
      value == undefined
    end
  end
end
