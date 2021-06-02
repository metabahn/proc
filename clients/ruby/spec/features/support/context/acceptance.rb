# frozen_string_literal: true

require "dotenv"
require "proc"

Dotenv.load

RSpec.shared_context "acceptance" do
  let(:client) {
    Proc.connect(authorization, client: client_class, **client_options)
  }

  let(:client_options) {
    {}
  }

  let(:client_class) {
    Proc::Client
  }

  let(:authorization) {
    ENV.fetch("SECRET")
  }

  def remove_auth_file
    backup_auth_file

    FileUtils.rm_f(auth_file_path)
  end

  def replace_auth_file(contents = authorization)
    backup_auth_file

    FileUtils.mkdir_p(auth_file_path.dirname)

    auth_file_path.open("w+") do |file|
      file.write(contents)
    end
  end

  def restore_auth_file
    if defined?(@existing_auth_file_contents)
      auth_file_path.open("w+") do |file|
        file.write(@existing_auth_file_contents)
      end
    end
  end

  def backup_auth_file
    if auth_file_path.exist?
      @existing_auth_file_contents = auth_file_path.read
    end
  end

  def auth_file_path
    @_auth_file_path ||= Pathname.new("~/.proc/auth").expand_path
  end
end
