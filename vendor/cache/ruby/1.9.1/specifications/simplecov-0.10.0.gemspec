# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "simplecov"
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph Olszowka"]
  s.date = "2015-04-18"
  s.description = "Code coverage for Ruby 1.9+ with a powerful configuration library and automatic merging of coverage across test suites"
  s.email = ["christoph at olszowka de"]
  s.homepage = "http://github.com/colszowka/simplecov"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "1.8.23.2"
  s.summary = "Code coverage for Ruby 1.9+ with a powerful configuration library and automatic merging of coverage across test suites"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, ["~> 1.8"])
      s.add_runtime_dependency(%q<simplecov-html>, ["~> 0.10.0"])
      s.add_runtime_dependency(%q<docile>, ["~> 1.1.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.9"])
    else
      s.add_dependency(%q<json>, ["~> 1.8"])
      s.add_dependency(%q<simplecov-html>, ["~> 0.10.0"])
      s.add_dependency(%q<docile>, ["~> 1.1.0"])
      s.add_dependency(%q<bundler>, ["~> 1.9"])
    end
  else
    s.add_dependency(%q<json>, ["~> 1.8"])
    s.add_dependency(%q<simplecov-html>, ["~> 0.10.0"])
    s.add_dependency(%q<docile>, ["~> 1.1.0"])
    s.add_dependency(%q<bundler>, ["~> 1.9"])
  end
end
