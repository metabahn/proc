# frozen_string_literal: true

require "open3"

module Helpers
  def stdout(options = "")
    stdout, _, _ = run(options)

    stdout.strip
  end

  def stderr(options = "")
    _, stderr, _ = run(options)

    stderr.strip
  end

  def status(options = "")
    _, _, status = run(options)

    status
  end

  def run(options = "")
    Open3.capture3("./proc #{options}")
  end

  def help(scope = :root)
    File.read(File.expand_path("../../../help/#{scope}.txt", __FILE__)).strip
  end

  def version
    File.read(File.expand_path("../../../VERSION", __FILE__)).strip
  end
end

RSpec.configure do |config|
  config.include Helpers
end
