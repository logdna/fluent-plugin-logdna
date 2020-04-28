# -*- encoding: utf-8 -*-
require 'date'

Gem::Specification.new do |s|
  s.name        = 'fluent-plugin-logdna'
  s.version     = '0.3.0'
  s.date        = Date.today.to_s
  s.summary     = 'LogDNA plugin for Fluentd'
  s.description = 'Fluentd plugin for supplying output to LogDNA.'
  s.authors     = ['Edwin Lai']
  s.email       = 'edwin@logdna.com'
  s.files       = ['lib/fluent/plugin/out_logdna.rb']
  s.homepage    = 'https://github.com/logdna/fluent-plugin-logdna'
  s.license     = 'MIT'

  s.require_paths = ['lib']
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.required_ruby_version = Gem::Requirement.new('>= 2.0.0')
  s.add_development_dependency "bundler", "~> 1.16"
  s.add_runtime_dependency 'fluentd', '>= 0.12.0', '< 2'
  s.add_runtime_dependency 'http', '~> 2.0', '>= 2.0.3'
end
