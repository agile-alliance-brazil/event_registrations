# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "abstract_type"
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Kubb"]
  s.date = "2013-10-28"
  s.description = "Module to declare abstract classes and methods"
  s.email = ["dan.kubb@gmail.com"]
  s.extra_rdoc_files = ["LICENSE", "README.md", "CONTRIBUTING.md", "TODO"]
  s.files = ["LICENSE", "README.md", "CONTRIBUTING.md", "TODO"]
  s.homepage = "https://github.com/dkubb/abstract_type"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Module to declare abstract classes and methods"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 1.3.5", "~> 1.3"])
    else
      s.add_dependency(%q<bundler>, [">= 1.3.5", "~> 1.3"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 1.3.5", "~> 1.3"])
  end
end
