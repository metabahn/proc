# frozen_string_literal: true

require File.expand_path("../lib/proc/composer/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name = "proc-composer"
  spec.version = Proc::Composer::VERSION
  spec.summary = "Proc composer library."
  spec.description = spec.summary

  spec.author = "Bryan Powell"
  spec.email = "bryan@metabahn.com"
  spec.homepage = "https://proc.dev"

  spec.required_ruby_version = ">= 3.0.0"

  spec.license = "MPL-2.0"

  spec.files = Dir["CHANGELOG.md", "README.md", "LICENSE", "lib/**/*"]
  spec.require_path = "lib"

  spec.add_dependency "core-inspect", "~> 0.1"
end
