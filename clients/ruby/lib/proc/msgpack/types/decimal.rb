# frozen_string_literal: true

require "bigdecimal"

class BigDecimal
  def to_msgpack(packer)
    if precision > 16
      packer.write(Proc::Msgpack::Types::Decimal.new(self))
      packer
    else
      to_f.to_msgpack(packer)
    end
  end
end

class Proc
  module Msgpack
    module Types
      class Decimal
        class << self
          def from_msgpack_ext(data)
            BigDecimal(data)
          end
        end

        def initialize(value)
          @value = value
        end

        def to_msgpack_ext
          @value.to_s
        end
      end
    end
  end
end
