# frozen_string_literal: true

require "date"

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-logdna"
  s.version     = "0.4.0"
  s.date        = Date.today.to_s
  s.summary     = "LogDNA Plugin for Fluentd"
  s.description = "Fluentd Plugin for Supplying Output to LogDNA."
  s.authors     = ["LogDNA, Inc."]
  s.email       = "help@logdna.com"
  s.homepage    = "https://github.com/logdna/fluent-plugin-logdna"
  s.license     = "MIT"

  s.require_paths = ["lib"]
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.required_ruby_version = Gem::Requirement.new(">= 2.3")
  s.add_runtime_dependency "fluentd", ">= 0.12.0", "< 2"
  s.add_runtime_dependency "http", "~> 2.0", ">= 2.0.3"
  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "rubocop", "~> 0.78"
end
