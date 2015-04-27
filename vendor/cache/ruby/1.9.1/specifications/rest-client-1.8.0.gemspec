# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rest-client"
  s.version = "1.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["REST Client Team"]
  s.date = "2015-03-24"
  s.description = "A simple HTTP and REST client for Ruby, inspired by the Sinatra microframework style of specifying actions: get, put, post, delete."
  s.email = "rest.client@librelist.com"
  s.executables = ["restclient"]
  s.extra_rdoc_files = ["README.rdoc", "history.md"]
  s.files = ["bin/restclient", "README.rdoc", "history.md"]
  s.homepage = "https://github.com/rest-client/rest-client"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "1.8.23.2"
  s.summary = "Simple HTTP and REST client for Ruby, inspired by microframework syntax for specifying actions."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<webmock>, ["~> 1.4"])
      s.add_development_dependency(%q<rspec>, ["~> 2.4"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<pry-doc>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["< 5.0", ">= 2.4.2"])
      s.add_runtime_dependency(%q<http-cookie>, ["< 2.0", ">= 1.0.2"])
      s.add_runtime_dependency(%q<mime-types>, ["< 3.0", ">= 1.16"])
      s.add_runtime_dependency(%q<netrc>, ["~> 0.7"])
    else
      s.add_dependency(%q<webmock>, ["~> 1.4"])
      s.add_dependency(%q<rspec>, ["~> 2.4"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<pry-doc>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["< 5.0", ">= 2.4.2"])
      s.add_dependency(%q<http-cookie>, ["< 2.0", ">= 1.0.2"])
      s.add_dependency(%q<mime-types>, ["< 3.0", ">= 1.16"])
      s.add_dependency(%q<netrc>, ["~> 0.7"])
    end
  else
    s.add_dependency(%q<webmock>, ["~> 1.4"])
    s.add_dependency(%q<rspec>, ["~> 2.4"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<pry-doc>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["< 5.0", ">= 2.4.2"])
    s.add_dependency(%q<http-cookie>, ["< 2.0", ">= 1.0.2"])
    s.add_dependency(%q<mime-types>, ["< 3.0", ">= 1.16"])
    s.add_dependency(%q<netrc>, ["~> 0.7"])
  end
end
