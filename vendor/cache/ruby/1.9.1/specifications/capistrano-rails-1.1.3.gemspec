# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "capistrano-rails"
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Clements", "Lee Hambley", "Kir Shatrov"]
  s.date = "2015-04-18"
  s.description = "Rails specific Capistrano tasks"
  s.email = ["seenmyfate@gmail.com", "lee.hambley@gmail.com", "shatrov@me.com"]
  s.homepage = "https://github.com/capistrano/rails"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Rails specific Capistrano tasks"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, ["~> 3.1"])
      s.add_runtime_dependency(%q<capistrano-bundler>, ["~> 1.1"])
    else
      s.add_dependency(%q<capistrano>, ["~> 3.1"])
      s.add_dependency(%q<capistrano-bundler>, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<capistrano>, ["~> 3.1"])
    s.add_dependency(%q<capistrano-bundler>, ["~> 1.1"])
  end
end
