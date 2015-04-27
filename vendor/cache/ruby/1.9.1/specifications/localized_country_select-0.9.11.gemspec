# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "localized_country_select"
  s.version = "0.9.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["karmi", "mlitwiniuk", "LIM SAS", "Damien MATHIEU", "Julien SANCHEZ", "Herv\\303\\251 GAUCHER", "RainerBlessing"]
  s.date = "2015-03-16"
  s.description = " Localized \"country_select\" helper with Rake task for downloading locales from Unicode.org's CLDR "
  s.email = [nil, "maciej@litwiniuk.net", nil, nil, nil, nil, nil]
  s.homepage = "https://github.com/mlitwiniuk/localized_country_select"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Localized \"country_select\" helper with Rake task for downloading locales from Unicode.org's CLDR"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionpack>, [">= 3.0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0"])
    else
      s.add_dependency(%q<actionpack>, [">= 3.0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<actionpack>, [">= 3.0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0"])
  end
end
