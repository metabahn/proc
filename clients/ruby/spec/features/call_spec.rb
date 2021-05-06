# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: call" do
  include_context "acceptance"

  it "calls a proc" do
    expect(client.call("core.ping")).to be(true)
  end

  it "calls a proc with input" do
    expect(client.call("core.echo", "foo")).to eq("foo")
  end

  it "calls a proc with input and arguments" do
    expect(client.call("type.string.truncate", "foo", length: 1)).to eq("f")
  end

  it "calls with composed input" do
    expect(client.call("type.string.truncate", client.core.echo("foo"), length: 1)).to eq("f")
  end

  it "calls with a composed argument" do
    expect(client.call("type.string.truncate", "foo", length: client.core.echo(1))).to eq("f")
  end
end
