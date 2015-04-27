# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "shellany"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cezary Baginski"]
  s.date = "2014-12-25"
  s.description = "MRI+JRuby compatible command output capturing"
  s.email = ["cezary@chronomantic.net"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Simple, somewhat portable command capturing"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.7"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.7"])
  end
end
