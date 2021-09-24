# frozen_string_literal: true

require "fileutils"
require "open3"

module Helpers
  def stdout(options = "", env: {})
    stdout, _, _ = run(options, env: env)

    stdout.strip
  end

  def stderr(options = "", env: {})
    _, stderr, _ = run(options, env: env)

    stderr.strip
  end

  def status(options = "", env: {})
    _, _, status = run(options, env: env)

    status
  end

  def run(options = "", env: {})
    env_string = env.map { |key, value|
      "#{key}=#{value}"
    }.join(" ")

    Open3.capture3("#{env_string} ./proc #{options}")
  end

  def help(scope = :root)
    File.read(File.expand_path("../../../help/#{scope}.txt", __FILE__)).strip
  end

  def version
    File.read(File.expand_path("../../../VERSION", __FILE__)).strip
  end

  def dot_proc_path
    @_dot_proc_path ||= Pathname.new("~/.proc").expand_path
  end
end

RSpec.configure do |config|
  config.include Helpers

  config.before do
    @dot_proc_backup_path = Pathname.new("~/.proc-backup").expand_path

    if File.directory?(dot_proc_path)
      FileUtils.mv(dot_proc_path, @dot_proc_backup_path)
      @restore_dot_proc = true
    end
  end

  config.after do
    if @restore_dot_proc
      FileUtils.rm_r(dot_proc_path) if dot_proc_path.exist?
      FileUtils.mv(@dot_proc_backup_path, dot_proc_path)
    end
  end
end
