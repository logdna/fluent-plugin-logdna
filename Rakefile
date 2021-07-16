# frozen_string_literal: true

require "set"
require "rake/clean"
require "rake/testtask"

# Directory to place gems to bundle with our main gem
PACKAGE_DIR = "pkg"
CLOBBER.include PACKAGE_DIR

desc "Copies gem dependencies to the #{PACKAGE_DIR} folder"
task "gemdep" do
  gem_copy gen_gem_list
end

desc "Copies gem dependencies which don't overlap with td-agent to the #{PACKAGE_DIR} folder"
task "gemdep:minimal" do
  MINIMAL_GEMS = %w[
    unf_ext
    unf
    domain_name
    http-cookie
    http-form_data
    http
  ].freeze
  gem_copy gen_gem_list MINIMAL_GEMS
end

def gen_gem_list(subset = [])
  myself = Bundler.load_gemspec(Dir[File.join(Bundler::SharedHelpers.pwd, "{,*}.gemspec")].first)
  to_pull = Set[]
  Bundler.locked_gems.specs.each do |spec|
    next if spec.name == myself.name

    if subset.empty?
      to_pull.add(spec)
    elsif subset.include? spec.name
      to_pull.add(spec)
    end
  end
  to_pull
end

# This assumes that bundle install has already been run (which populates
# Bundler.app_cache with the gems of dependencies).
def gem_copy(specs)
  Bundler.mkdir_p PACKAGE_DIR
  sources = specs.map { |s| Bundler.app_cache.join "#{s.full_name}.gem" }
  FileUtils.cp sources, PACKAGE_DIR, verbose: true
end

Rake::TestTask.new do |task|
  task.pattern = "test/**/*.rb"
end
