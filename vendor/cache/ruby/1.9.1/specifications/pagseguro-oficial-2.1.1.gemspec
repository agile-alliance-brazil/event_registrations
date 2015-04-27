# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pagseguro-oficial"
  s.version = "2.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nando Vieira"]
  s.date = "2015-04-01"
  s.description = "Biblioteca oficial de integra\u{e7}\u{e3}o PagSeguro em Ruby"
  s.email = ["fnando.vieira@gmail.com"]
  s.homepage = "http://www.pagseguro.com.br"
  s.licenses = ["ASL"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "1.8.23.2"
  s.summary = "Biblioteca oficial de integra\u{e7}\u{e3}o PagSeguro em Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<aitch>, [">= 0.2.1"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<autotest-standalone>, [">= 0"])
      s.add_development_dependency(%q<test_notifier>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
    else
      s.add_dependency(%q<aitch>, [">= 0.2.1"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<autotest-standalone>, [">= 0"])
      s.add_dependency(%q<test_notifier>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
    end
  else
    s.add_dependency(%q<aitch>, [">= 0.2.1"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<autotest-standalone>, [">= 0"])
    s.add_dependency(%q<test_notifier>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
  end
end
