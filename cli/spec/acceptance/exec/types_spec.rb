# frozen_string_literal: true

RSpec.describe "handling return types from exec" do
  it "handles strings" do
    expect(stdout("exec procs/exec/types/string.rb")).to eq("foo")
  end

  it "handles integers" do
    expect(stdout("exec procs/exec/types/integer.rb")).to eq("42")
  end

  it "handles decimals" do
    expect(stdout("exec procs/exec/types/decimal.rb")).to eq("42.42")
  end

  it "handles booleans" do
    expect(stdout("exec procs/exec/types/boolean.rb")).to eq("true")
  end

  it "handles hashes" do
    expect(stdout("exec procs/exec/types/hash.rb")).to eq("{}")
  end

  it "handles arrays" do
    expect(stdout("exec procs/exec/types/array.rb")).to eq("[]")
  end
end
