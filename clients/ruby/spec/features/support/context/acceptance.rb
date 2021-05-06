# frozen_string_literal: true

require "dotenv"
require "proc"

Dotenv.load

RSpec.shared_context "acceptance" do
  let(:client) {
    Proc.connect(authorization, **client_options)
  }

  let(:client_options) {
    {}
  }

  let(:authorization) {
    ENV.fetch("SECRET")
  }
end
