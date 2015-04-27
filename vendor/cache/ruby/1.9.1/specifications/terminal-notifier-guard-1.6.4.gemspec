# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "terminal-notifier-guard"
  s.version = "1.6.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran", "Wouter de Vos"]
  s.date = "2014-11-03"
  s.email = ["wouter@springest.com"]
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown"]
  s.homepage = "https://github.com/Springest/terminal-notifier-guard"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Send User Notifications on Mac OS X 10.8 - with status icons."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<bacon>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<mocha-on-bacon>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<bacon>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<bacon>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
  end
end
