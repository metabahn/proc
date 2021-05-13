# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: undefined" do
  include_context "acceptance"

  it "does not pass undefined input to calls" do
    expect {
      client["core.echo"].call
    }.to raise_error(Proc::Invalid, "proc `core.echo' does not accept an undefined input")
  end

  it "does not pass undefined input to compositions" do
    composition = client.core.echo >> client.core.echo

    expect {
      composition.call
    }.to raise_error(Proc::Invalid, "proc `core.echo' does not accept an undefined input")
  end

  it "does not confuse nil with undefined" do
    expect(client["core.echo"].call(nil)).to be(nil)
  end
end
