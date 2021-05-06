# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: dynamic" do
  include_context "acceptance"

  it "calls dynamic procs" do
    expect(client.core.ping.call).to be(true)
  end

  it "calls dynamic procs looked up with input" do
    expect(client.core.echo("foo").call).to eq("foo")
  end

  it "calls dynamic procs with input" do
    expect(client.core.echo.call("foo")).to eq("foo")
  end

  it "calls dynamic procs with input that were looked up with input" do
    expect(client.core.echo("foo").call("bar")).to eq("bar")
  end

  it "calls nested dynamic procs with default input and arguments" do
    expect(client.type.string.truncate("foo", length: 1).call).to eq("f")
  end

  it "calls nested dynamic procs with default input and arguments given to a previous lookup" do
    expect(client.type.string("foo", length: 1).truncate.call).to eq("f")
  end

  it "calls nested dynamic procs with default arguments given to a previous lookup and new input" do
    expect(client.type.string("foo", length: 1).truncate("bar").call).to eq("b")
  end

  it "calls nested dynamic procs with default input and dynamic arguments" do
    expect(client.type.string.truncate("foo").call(length: 1)).to eq("f")
  end

  it "calls nested dynamic procs with default arguments and dynamic input" do
    expect(client.type.string.truncate(length: 1).call("foo")).to eq("f")
  end

  it "calls nested dynamic procs with dynamic input and arguments" do
    expect(client.type.string.truncate("foo", length: 1).call("bar", length: 2)).to eq("ba")
  end

  describe "hash lookup" do
    it "is supported on client" do
      expect(client["core.echo"].call("foo")).to eq("foo")
    end

    it "is supported on callables" do
      expect(client.type.string["reverse"].call("foo")).to eq("oof")
    end
  end

  describe "using with" do
    subject {
      client.core.echo.with("foo")
    }

    it "creates a new callable context" do
      expect(subject.call).to eq("foo")
    end

    it "can be overridden like any other callable" do
      expect(subject.call("bar")).to eq("bar")
    end

    describe "complex case using input and arguments" do
      subject {
        client.type.string.truncate.with("foo", length: 1)
      }

      it "can be called" do
        expect(subject.call).to eq("f")
      end

      it "can have its input overridden" do
        expect(subject.call("bar")).to eq("b")
      end

      it "can have its arguments overridden" do
        expect(subject.call(length: 2)).to eq("fo")
      end

      it "can have its inputs and arguments overridden" do
        expect(subject.call("bar", length: 2)).to eq("ba")
      end
    end
  end
end
