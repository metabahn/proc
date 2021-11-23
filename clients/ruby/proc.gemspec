# frozen_string_literal: true

require File.expand_path("../lib/proc/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name = "proc"
  spec.version = Proc::VERSION
  spec.summary = "Proc client library."
  spec.description = spec.summary

  spec.author = "Bryan Powell"
  spec.email = "bryan@metabahn.com"
  spec.homepage = "https://proc.dev"

  spec.required_ruby_version = ">= 3.0.0"

  spec.license = "MPL-2.0"

  spec.files = Dir["CHANGELOG.md", "README.md", "LICENSE", "lib/**/*"]
  spec.require_path = "lib"

  spec.add_dependency "core-async", "~> 0.6"
  spec.add_dependency "core-global", "~> 0.0"
  spec.add_dependency "core-inspect", "~> 0.1"
  spec.add_dependency "http", "~> 5.0"
  spec.add_dependency "msgpack", "~> 1.4"
  spec.add_dependency "proc-composer", "~> 0.0"
end
