# frozen_string_literal: true

class Proc
  class Enumerator
    include Enumerable

    attr_reader :values, :next_block

    def initialize(values, &next_block)
      @values = values
      @next_block = next_block
    end

    # [public] Calls the given block once for each value.
    #
    def each(enumerable = self, &block)
      return to_enum(:each) unless block

      while enumerable
        enumerable.values.each(&block)
        enumerable = enumerable.next_block&.call
      end
    end
  end
end
