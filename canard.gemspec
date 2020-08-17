# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: canard 0.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "canard".freeze
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lloyd Kranzky".freeze]
  s.date = "2020-08-17"
  s.description = "TDD is 'canard. Rubber-ducking is 'cneasy.".freeze
  s.email = "lloyd@kranzky.com".freeze
  s.executables = ["canard".freeze]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rubocop.yml",
    ".ruby-gemset",
    ".ruby-version",
    ".semver",
    "Gemfile",
    "Gemfile.lock",
    "QUACKS.md",
    "README.md",
    "Rakefile",
    "UNLICENSE",
    "bin/canard",
    "lib/canard.rb",
    "lib/canard/bowling.rb",
    "lib/canard/canard.rb",
    "mockup.rb",
    "spec/frame_spec.rb",
    "spec/game_spec.rb"
  ]
  s.homepage = "http://github.com/kranzky/canard".freeze
  s.licenses = ["UNLICENSE".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.1".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "A waterfowl development methodology.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<debug_inspector>.freeze, ["~> 0.0.3"])
    s.add_runtime_dependency(%q<semver2>.freeze, ["~> 3"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.9"])
    s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<rdoc>.freeze, ["~> 6.2"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.1"])
    s.add_development_dependency(%q<juwelier>.freeze, ["~> 2.4"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.19"])
  else
    s.add_dependency(%q<debug_inspector>.freeze, ["~> 0.0.3"])
    s.add_dependency(%q<semver2>.freeze, ["~> 3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.9"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 6.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.1"])
    s.add_dependency(%q<juwelier>.freeze, ["~> 2.4"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.19"])
  end
end

