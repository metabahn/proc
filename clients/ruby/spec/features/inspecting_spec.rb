# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "inspecting" do
  let(:client) {
    Proc.connect
  }

  it "can inspect the client" do
    expect(client.inspect).to match(/#{client_inspection}/)
  end

  it "can inspect a callable" do
    callable = client.core.echo

    expect(callable.inspect).to match(/#{callable_inspection(callable)}/)
  end

  it "can inspect a composition" do
    composition = client.type.string.reverse >> client.type.string.upcase

    expect(composition.inspect).to match(/#{composition_inspection(composition)}/)
  end

  it "can inspect an enumerator" do
    enumerator = Proc::Enumerator.new([0, 1, 2])

    expect(enumerator.inspect).to match(/#<Proc::Enumerator:0x[a-zA-Z0-9]+, @values=\[0, 1, 2\]>/)
  end

  private def client_inspection
    "#<Proc::Client:0x[a-zA-Z0-9]+, @scheme=\"https\", @host=\"proc.run\", @authorization=\"#{client.safe_authorization}\", @count=0>"
  end

  private def callable_inspection(callable)
    "#<Proc::Callable:0x[a-zA-Z0-9]+, @proc=\"#{callable.proc}\", @input=\"\\(undefined\\)\", @arguments={}, @client=#{client_inspection}>"
  end

  private def composition_inspection(composition)
    callable_inspections = composition.callables.map { |callable|
      callable_inspection(callable)
    }

    "#<Proc::Composition:0x[a-zA-Z0-9]+, @input=\"\\(undefined\\)\", @arguments={}, @callables=\\[#{callable_inspections.join(", ")}\\], @client=#{client_inspection}>"
  end
end
