# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "poltergeist"
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jon Leighton"]
  s.date = "2015-02-05"
  s.description = "Poltergeist is a driver for Capybara that allows you to run your tests on a headless WebKit browser, provided by PhantomJS."
  s.email = ["j@jonathanleighton.com"]
  s.homepage = "http://github.com/teampoltergeist/poltergeist"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "1.8.23.2"
  s.summary = "PhantomJS driver for Capybara"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capybara>, ["~> 2.1"])
      s.add_runtime_dependency(%q<websocket-driver>, [">= 0.2.0"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_runtime_dependency(%q<cliver>, ["~> 0.3.1"])
      s.add_development_dependency(%q<launchy>, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.12"])
      s.add_development_dependency(%q<sinatra>, ["~> 1.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<image_size>, ["~> 1.0"])
      s.add_development_dependency(%q<pdf-reader>, ["~> 1.3.3"])
      s.add_development_dependency(%q<coffee-script>, ["~> 2.2.0"])
      s.add_development_dependency(%q<guard-coffeescript>, ["~> 1.0.0"])
      s.add_development_dependency(%q<rspec-rerun>, ["~> 0.1"])
    else
      s.add_dependency(%q<capybara>, ["~> 2.1"])
      s.add_dependency(%q<websocket-driver>, [">= 0.2.0"])
      s.add_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_dependency(%q<cliver>, ["~> 0.3.1"])
      s.add_dependency(%q<launchy>, ["~> 2.0"])
      s.add_dependency(%q<rspec>, ["~> 2.12"])
      s.add_dependency(%q<sinatra>, ["~> 1.0"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<image_size>, ["~> 1.0"])
      s.add_dependency(%q<pdf-reader>, ["~> 1.3.3"])
      s.add_dependency(%q<coffee-script>, ["~> 2.2.0"])
      s.add_dependency(%q<guard-coffeescript>, ["~> 1.0.0"])
      s.add_dependency(%q<rspec-rerun>, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<capybara>, ["~> 2.1"])
    s.add_dependency(%q<websocket-driver>, [">= 0.2.0"])
    s.add_dependency(%q<multi_json>, ["~> 1.0"])
    s.add_dependency(%q<cliver>, ["~> 0.3.1"])
    s.add_dependency(%q<launchy>, ["~> 2.0"])
    s.add_dependency(%q<rspec>, ["~> 2.12"])
    s.add_dependency(%q<sinatra>, ["~> 1.0"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<image_size>, ["~> 1.0"])
    s.add_dependency(%q<pdf-reader>, ["~> 1.3.3"])
    s.add_dependency(%q<coffee-script>, ["~> 2.2.0"])
    s.add_dependency(%q<guard-coffeescript>, ["~> 1.0.0"])
    s.add_dependency(%q<rspec-rerun>, ["~> 0.1"])
  end
end
