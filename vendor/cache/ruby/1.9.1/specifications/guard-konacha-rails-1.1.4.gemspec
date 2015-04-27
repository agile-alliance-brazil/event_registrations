# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "guard-konacha-rails"
  s.version = "1.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Leonid Beder"]
  s.date = "2015-02-13"
  s.description = "Guard plugin for the konacha testing framework."
  s.email = ["leonid.beder@gmail.com"]
  s.homepage = "https://github.com/lbeder/guard-konacha-rails"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Guard plugin for the konacha testing framework"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<guard>, [">= 2"])
      s.add_runtime_dependency(%q<rails>, [">= 4.0"])
      s.add_runtime_dependency(%q<konacha>, [">= 3.0"])
      s.add_runtime_dependency(%q<guard-compat>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 3"])
      s.add_development_dependency(%q<coveralls>, [">= 0"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<poltergeist>, [">= 0"])
    else
      s.add_dependency(%q<guard>, [">= 2"])
      s.add_dependency(%q<rails>, [">= 4.0"])
      s.add_dependency(%q<konacha>, [">= 3.0"])
      s.add_dependency(%q<guard-compat>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 3"])
      s.add_dependency(%q<coveralls>, [">= 0"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<poltergeist>, [">= 0"])
    end
  else
    s.add_dependency(%q<guard>, [">= 2"])
    s.add_dependency(%q<rails>, [">= 4.0"])
    s.add_dependency(%q<konacha>, [">= 3.0"])
    s.add_dependency(%q<guard-compat>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 3"])
    s.add_dependency(%q<coveralls>, [">= 0"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<poltergeist>, [">= 0"])
  end
end
