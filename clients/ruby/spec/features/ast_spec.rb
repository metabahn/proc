# frozen_string_literal: true

require_relative "support/context/acceptance"

require "proc/clients/ast"

RSpec.describe "ruby client api: building asts" do
  include_context "acceptance"

  let(:client_class) {
    Proc::Clients::AST
  }

  it "builds the ast for simple calls" do
    expect(client.core.echo("foo").call).to eq([["$$", "proc", ["{}", ["()", "core.echo", [">>", ["%%", "foo"]]]]]])
  end

  it "builds the ast for compositions" do
    expect((client.core.echo("foo") >> client.core.echo).call).to eq(
      [
        [
          "$$", "proc", [
            "{}",
            [">>", ["%%", "foo"]],
            ["()", "core.echo", [">>", ["%%", "foo"]]],
            ["()", "core.echo"]
          ]
        ]
      ]
    )
  end
end
