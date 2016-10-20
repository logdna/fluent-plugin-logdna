Gem::Specification.new do |s|
  s.name        = 'fluent-plugin-logdna'
  s.version     = '0.0.0'
  s.date        = '2016-10-20'
  s.summary     = "LogDNA plugin for Fluentd"
  s.description = "This is the LogDNA plugin for Fluentd."
  s.authors     = ["Edwin Lai"]
  s.email       = 'edwin@logdna.com'
  s.files       = ["lib/fluent/plugin/out_logdna.rb"]
  s.homepage    = 'https://github.com/logdna/fluent-plugin-logdna'
  s.license     = 'MIT'

  s.require_paths = ['lib']
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0-p648")
  s.add_dependency('http', '~> 2.0.3')
end