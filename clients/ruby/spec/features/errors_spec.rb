# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "errors" do
  include_context "acceptance"

  context "secret is missing" do
    let(:authorization) {
      nil
    }

    it "raises with the expected message" do
      expect {
        client["core.echo"].call("echo")
      }.to raise_error(Proc::Unauthorized, "authorization is missing")
    end
  end

  context "secret is invalid" do
    let(:authorization) {
      "12321"
    }

    it "raises with the expected message" do
      expect {
        client["core.echo"].call("echo")
      }.to raise_error(Proc::Unauthorized, "authorization is invalid")
    end
  end

  context "proc does not exist" do
    it "raises with the expected message" do
      expect {
        client["foo.bar.baz"].call
      }.to raise_error(Proc::Undefined, "undefined proc `foo.bar.baz'")
    end
  end

  context "input is of the wrong type" do
    it "raises with the expected message" do
      expect {
        client["type.string.truncate"].call(["foo"], length: 1)
      }.to raise_error(Proc::Invalid, "proc `type.string.truncate' does not accept the given input")
    end
  end

  context "authorization cannot access the given ability" do
    let(:limited_authorization) {
      client["auth.create"].call(abilities: ["string"])
    }

    it "raises with the expected message" do
      expect {
        Proc.connect(limited_authorization)["core.echo"].call("foo")
      }.to raise_error(Proc::Unauthorized, "authorization does not have the ability to access proc `core.echo'")
    end
  end

  context "server is unreachable" do
    let(:client_options) {
      {scheme: "http", host: "unknown"}
    }

    it "raises with the expected message" do
      expect {
        client["core.echo"].call("foo")
      }.to raise_error(Proc::Unavailable) do |error|
        expect(error.cause.message).to include("failed to connect: getaddrinfo:")
      end
    end
  end

  context "authorization is invalid" do
    let(:authorization) {
      "aaa.bbb.ccc"
    }

    it "raises with the expected message" do
      expect {
        client["core.echo"].call("foo")
      }.to raise_error(Proc::Unauthorized, "authorization is invalid")
    end
  end

  context "proc exceeds max execution time" do
    it "raises with the expected message" do
      expect {
        client["core.sleep"].call(seconds: 6)
      }.to raise_error(Proc::Timeout, "forced to stop after 5s")
    end
  end

  context "request is too large" do
    it "raises with the expected message" do
      expect {
        client["core.echo"].call("foo" * 1024 * 128)
      }.to raise_error(Proc::Invalid, "request size exceeded the allowed 131072 bytes")
    end
  end
end
