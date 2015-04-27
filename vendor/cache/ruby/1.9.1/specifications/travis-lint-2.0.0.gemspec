# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "travis-lint"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Travis CI GmbH"]
  s.date = "2014-07-16"
  s.description = "DEPRECATED: Use `travis lint` (from travis gem) instead"
  s.email = "support@travis-ci.com"
  s.executables = ["travis-lint"]
  s.files = ["bin/travis-lint"]
  s.homepage = "https://travis-ci.com"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Checks your .travis.yml for possible issues, deprecations and so on"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
  end
end
