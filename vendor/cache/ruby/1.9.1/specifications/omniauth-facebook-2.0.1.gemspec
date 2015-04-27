# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "omniauth-facebook"
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Dodwell", "Josef \u{160}im\u{e1}nek"]
  s.date = "2015-02-21"
  s.email = ["mark@madeofcode.com", "retro@ballgag.cz"]
  s.homepage = "https://github.com/mkdynamic/omniauth-facebook"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Facebook OAuth2 Strategy for OmniAuth"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth-oauth2>, ["~> 1.2"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<omniauth-oauth2>, ["~> 1.2"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<omniauth-oauth2>, ["~> 1.2"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
