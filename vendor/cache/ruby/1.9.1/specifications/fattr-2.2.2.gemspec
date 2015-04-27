# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fattr"
  s.version = "2.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ara T. Howard"]
  s.date = "2014-02-15"
  s.description = "a \"fatter attr\" for ruby"
  s.email = "ara.t.howard@gmail.com"
  s.homepage = "https://github.com/ahoward/fattr"
  s.licenses = ["same as ruby's"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "codeforpeople"
  s.rubygems_version = "1.8.23.2"
  s.summary = "fattr"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
