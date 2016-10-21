# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'fluent-plugin-logdna'
  s.version     = '0.0.2'
  s.date        = '2016-10-20'
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
  s.add_runtime_dependency 'http', '~> 2.0', '>= 2.0.3'
end
