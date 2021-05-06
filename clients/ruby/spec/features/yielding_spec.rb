# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: yielding" do
  include_context "acceptance"

  it "yields to chains" do
    expect(
      client.enum.map {
        client["type.string.reverse"]
      }.call(["foo", "bar", "baz"])
    ).to eq(["oof", "rab", "zab"])
  end

  it "yields to the proc arg" do
    expect(
      client.enum.map.call(["foo", "bar", "baz"], proc: client["type.string.reverse"])
    ).to eq(["oof", "rab", "zab"])
  end

  it "yields to client lookups" do
    expect(
      client["enum.map"] {
        client["type.string.reverse"]
      }.call(["foo", "bar", "baz"])
    ).to eq(["oof", "rab", "zab"])
  end

  it "yields to callable lookups" do
    expect(
      client.enum["map"] {
        client["type.string.reverse"]
      }.call(["foo", "bar", "baz"])
    ).to eq(["oof", "rab", "zab"])
  end

  it "yields to callable with" do
    expect(
      client["enum.map"].with(["foo", "bar", "baz"]) {
        client["type.string.reverse"]
      }.call
    ).to eq(["oof", "rab", "zab"])
  end
end
