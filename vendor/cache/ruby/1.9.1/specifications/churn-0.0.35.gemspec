# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "churn"
  s.version = "0.0.35"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Mayer"]
  s.date = "2012-12-17"
  s.description = "High method and class churn has been shown to have increased bug and error rates. This gem helps you know what is changing a lot so you can do additional testing, code review, or refactoring to try to tame the volatile code. "
  s.email = "dan@mayerdan.com"
  s.executables = ["churn"]
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.files = ["bin/churn", "LICENSE", "README.md"]
  s.homepage = "http://github.com/danmayer/churn"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "churn"
  s.rubygems_version = "1.8.23.2"
  s.summary = "Providing additional churn metrics over the original metric_fu churn"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<test-construct>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9.5"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_runtime_dependency(%q<main>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_runtime_dependency(%q<sexp_processor>, ["~> 4.1"])
      s.add_runtime_dependency(%q<ruby_parser>, ["~> 3.0"])
      s.add_runtime_dependency(%q<hirb>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 1.6.0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<test-construct>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<mocha>, ["~> 0.9.5"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<main>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_dependency(%q<sexp_processor>, ["~> 4.1"])
      s.add_dependency(%q<ruby_parser>, ["~> 3.0"])
      s.add_dependency(%q<hirb>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 1.6.0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<test-construct>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<mocha>, ["~> 0.9.5"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<main>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<chronic>, [">= 0.2.3"])
    s.add_dependency(%q<sexp_processor>, ["~> 4.1"])
    s.add_dependency(%q<ruby_parser>, ["~> 3.0"])
    s.add_dependency(%q<hirb>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 1.6.0"])
  end
end
