# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: numerics" do
  include_context "acceptance"

  it "handles integers" do
    expect(client["core.echo"].call(123)).to be_instance_of(Integer)
    expect(client["core.echo"].call(123)).to eq(123)
  end

  it "handles floats" do
    expect(client["core.echo"].call(1.23)).to be_instance_of(Float)
    expect(client["core.echo"].call(1.23)).to eq(1.23)
  end

  it "handles decimals" do
    expect(client["core.echo"].call(BigDecimal("100000000000043.298349238472398"))).to be_instance_of(BigDecimal)
    expect(client["core.echo"].call(BigDecimal("100000000000043.298349238472398"))).to eq(BigDecimal("100000000000043.298349238472398"))
  end
end
