# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: composition" do
  include_context "acceptance"

  let(:string) {
    client.type.string
  }

  it "composes two procs" do
    composition = string.reverse >> string.capitalize

    expect(composition.call("foo")).to eq("Oof")
  end

  it "uses arguments correctly" do
    composition = string.reverse >> string.truncate(length: 2)

    expect(composition.call("hello")).to eq("ol")
  end

  it "uses default input and arguments correctly" do
    composition = string.reverse("foo") >> string.truncate(length: 2)

    expect(composition.call).to eq("oo")
  end

  it "prefers the given input" do
    composition = string.reverse("foo") >> string.truncate(length: 2)

    expect(composition.call("bar")).to eq("oo")
  end

  it "calls a proc with callable input" do
    input = client.core.echo("foo")

    expect(client.call("type.string.truncate", input, length: 1)).to eq("f")
  end

  it "calls a proc with a callable argument" do
    length = client.core.echo(1)

    expect(client.call("type.string.truncate", "foo", length: length)).to eq("f")
  end

  it "calls a proc with a callable input that has its own callable input" do
    input = client.core.echo("foo")

    capitalized = client.type.string.capitalize(input)

    expect(client.call("type.string.truncate", capitalized, length: 1)).to eq("F")
  end

  it "calls a proc with a callable argument that has its own callable argument" do
    client.call("keyv.set", bucket: "bucket", key: "length", value: 2)

    key = client.core.echo("length")

    length = client.keyv.get(bucket: "bucket", key: key)

    expect(client.call("type.string.truncate", "foo", length: length)).to eq("fo")
  end

  it "calls a proc with composed input" do
    input = client.core.echo("foo") >> client.type.string.reverse

    expect(client.call("type.string.truncate", input, length: 1)).to eq("o")
  end

  it "calls a proc with a composed argument" do
    client.call("keyv.set", bucket: "bucket", key: "yekym", value: "a-value")

    key = client.core.echo("mykey") >> client.type.string.reverse

    expect(client.keyv.get(bucket: "bucket", key: key).call).to eq("a-value")
  end

  it "calls a composition with a composed input" do
    expect(
      (
        client.type.string.reverse >>
          client.core.echo.with(
            client.type.string.capitalize >>
              client.type.string.truncate(length: 2) >>
              client.type.string.reverse
          )
      ).call("foo")
    ).to eq("oO")
  end

  it "fails when a composition calls a proc with invalid arguments" do
    composition = string.reverse("foo") >> string.truncate

    expect {
      composition.call
    }.to raise_error(Proc::Invalid, "invalid argument `length' for `type.string.truncate' (is required)")
  end

  it "fails when a composition calls an undefined proc" do
    composition = string.reverse("foo") >> string.missing

    expect {
      composition.call
    }.to raise_error(Proc::Undefined) do |error|
      expect(error.message).to start_with("undefined proc `type.string.missing'; try one of:")
    end
  end

  describe "using with" do
    it "calls the composition with the given input" do
      composition = string.reverse >> string.truncate(length: 1)

      expect(composition.with("bar").call).to eq("r")
    end

    it "ignores arguments since the scope for use is unknown" do
      composition = string.reverse >> string.truncate(length: 1)

      expect(composition.call("bar", length: 3)).to eq("r")
    end

    it "ignores arguments given to with since the scope for use is unknown" do
      composition = string.reverse >> string.truncate(length: 1)

      expect(composition.with("bar", length: 3).call).to eq("r")
    end
  end

  describe "composing compositions" do
    it "composes the compositions" do
      composition1 = client.core.echo("foo") >> string.reverse
      composition2 = string.truncate(length: 1) >> string.capitalize
      composition = composition1 >> composition2

      expect(composition.call).to eq("O")
    end
  end

  describe "using compose" do
    it "composes a callable" do
      composition = string.reverse.compose(string.capitalize)

      expect(composition.call("foo")).to eq("Oof")
    end

    it "composes a composition" do
      composition1 = client.core.echo("foo") >> string.reverse
      composition2 = string.truncate(length: 1) >> string.capitalize
      composition = composition1.compose(composition2)

      expect(composition.call).to eq("O")
    end

    it "composes many" do
      composition = string.reverse.compose(string.capitalize, string.reverse)

      expect(composition.call("foo")).to eq("foO")
    end
  end
end
