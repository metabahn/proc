# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: using the global instance" do
  include_context "acceptance"

  before do
    ENV["PROC_AUTH"] = authorization
    Proc::Client.reset
  end

  after do
    ENV.delete("PROC_AUTH")
  end

  it "can call proc" do
    expect(Proc::Client.core.echo.call(123)).to eq(123)
  end

  describe "authorization" do
    context "PROC_AUTH environment variable is not defined" do
      before do
        ENV.delete("PROC_AUTH")
      end

      context "proc auth file exists" do
        before do
          replace_auth_file
        end

        after do
          restore_auth_file
        end

        it "uses the proc auth file" do
          expect(Proc::Client.core.echo.call(123)).to eq(123)
        end
      end

      context "proc auth file does not exist" do
        before do
          remove_auth_file
        end

        after do
          restore_auth_file
        end

        it "fails to authorize" do
          expect {
            Proc::Client.core.echo.call(123)
          }.to raise_error(Proc::Unauthorized)
        end
      end
    end

    context "PROC_AUTH environment variable is defined" do
      context "proc auth file exists" do
        before do
          replace_auth_file("invalid")
        end

        after do
          restore_auth_file
        end

        it "prefers the environment variable" do
          expect(Proc::Client.core.echo.call(123)).to eq(123)
        end
      end
    end
  end
end
