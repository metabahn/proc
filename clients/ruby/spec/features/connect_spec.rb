# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: connect" do
  include_context "acceptance"

  it "connects and returns a client" do
    expect(Proc.connect(authorization)).to be_instance_of(Proc::Client)
  end
end
