# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: arguments" do
  include_context "acceptance"

  describe "using an argument reference as input in a call" do
    let(:proc) {
      client.core.echo(client.argument(:foo))
    }

    it "uses the given argument as input" do
      expect(proc.call(foo: "foo")).to eq("foo")
    end
  end

  describe "using an argument reference to require an argument in a call" do
    let(:proc) {
      client.type.string.truncate(length: client.argument(:truncate_to))
    }

    it "uses the given argument in the call" do
      expect(proc.call("foo", truncate_to: 2)).to eq("fo")
    end

    it "uses the given argument using with" do
      expect(proc.with(truncate_to: 2).call("foo")).to eq("fo")
    end

    it "uses complex argument values" do
      expect(proc.call("foo", truncate_to: client.core.echo(2))).to eq("fo")
    end

    it "fails when the argument is not given" do
      expect {
        proc.call("foo")
      }.to raise_error(Proc::Invalid, "invalid argument `truncate_to' for `type.string.truncate' (is required)")
    end

    context "argument name conflicts with the argument needed by the call" do
      let(:proc) {
        client.type.string.truncate(length: client.argument(:length))
      }

      it "uses the given argument in the call" do
        expect(proc.call("foo", length: 2)).to eq("fo")
      end
    end
  end

  describe "using an argument reference as input in a composition" do
    let(:composition) {
      client.type.string.reverse(client.argument(:foo)) >> client.type.string.truncate(length: 2)
    }

    it "uses the given argument value as input" do
      expect(composition.call(foo: "bar")).to eq("ra")
    end

    it "uses the given argument value as input using with" do
      expect(composition.with(foo: "bar").call).to eq("ra")
    end

    it "uses complex argument values" do
      expect(composition.call(foo: client.core.echo("bar"))).to eq("ra")
    end
  end

  describe "using an argument reference to require an argument in a composition" do
    let(:composition) {
      client.type.string.reverse >> client.type.string.truncate(length: client.argument(:truncate_to))
    }

    it "uses the given argument in the composition" do
      expect(composition.call("foo", truncate_to: 1)).to eq("o")
    end

    it "uses the given argument in the composition using with" do
      expect(composition.with(truncate_to: 1).call("foo")).to eq("o")
    end

    it "uses complex argument values" do
      expect(composition.call("foo", truncate_to: client.core.echo(1))).to eq("o")
    end

    it "fails when the argument is not passed" do
      expect {
        composition.call("foo")
      }.to raise_error(Proc::Invalid, "invalid argument `truncate_to' for `type.string.truncate' (is required)")
    end

    context "argument name conflicts with the argument needed by the call" do
      let(:composition) {
        client.type.string.reverse >> client.type.string.truncate(length: client.argument(:length))
      }

      it "uses the given argument in the call" do
        expect(composition.call("foo", length: 1)).to eq("o")
      end
    end
  end

  describe "passing a complex value to an argument reference in a composition" do
    let(:composition) {
      client.type.string.reverse >> client.type.string.truncate(length: client.argument(:truncate_to))
    }

    it "resolves the complex value correctly" do
      expect(composition.call("foo", truncate_to: client.core.echo(1))).to eq("o")
    end
  end

  describe "using an argument reference with a default value in a composition" do
    let(:composition) {
      client.type.string.reverse >> client.type.string.truncate(length: client.argument(:truncate_to, default: 2))
    }

    it "uses argument references for a composition" do
      expect(composition.call("foo", truncate_to: 1)).to eq("o")
    end

    it "falls back to the default value when not passed" do
      expect(composition.call("foo")).to eq("oo")
    end
  end

  describe "using an argument reference with a complex default value in a composition" do
    let(:composition) {
      echo = client.core.echo(2)

      client.type.string.reverse >> client.type.string.truncate(length: client.argument(:truncate_to, default: echo))
    }

    it "falls back to the default value when not passed" do
      expect(composition.call("foo")).to eq("oo")
    end
  end

  describe "coercing an argument reference" do
    it "coerces the value correctly" do
      expect(client.core.echo(client.arg(:foo, type: :integer)).call(foo: "1")).to eq(1)
    end
  end

  describe "using the convenience method to define an argument reference" do
    let(:composition) {
      client.type.string.reverse >> client.type.string.truncate(length: client.arg(:truncate_to))
    }

    it "uses the argument references" do
      expect(composition.call("foo", truncate_to: 1)).to eq("o")
    end
  end

  describe "using symbols as arguments for input" do
    let(:proc) {
      client.core.echo(:foo)
    }

    it "uses the given argument as input" do
      expect(proc.call(foo: "foo")).to eq("foo")
    end
  end

  describe "using an argument reference to require an argument in a call" do
    let(:proc) {
      client.type.string.truncate(length: :truncate_to)
    }

    it "uses the given argument in the call" do
      expect(proc.call("foo", truncate_to: 2)).to eq("fo")
    end
  end
end
