# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "unparser"
  s.version = "0.1.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Markus Schirp"]
  s.date = "2014-11-07"
  s.description = "Generate equivalent source for parser gem AST nodes"
  s.email = "mbj@schir-dso.com"
  s.executables = ["unparser"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["bin/unparser", "README.md"]
  s.homepage = "http://github.com/mbj/unparser"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "1.8.23.2"
  s.summary = "Generate equivalent source for parser gem AST nodes"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parser>, ["~> 2.2.0.pre.7"])
      s.add_runtime_dependency(%q<procto>, ["~> 0.0.2"])
      s.add_runtime_dependency(%q<concord>, ["~> 0.1.5"])
      s.add_runtime_dependency(%q<adamantium>, ["~> 0.2.0"])
      s.add_runtime_dependency(%q<equalizer>, ["~> 0.0.9"])
      s.add_runtime_dependency(%q<abstract_type>, ["~> 0.0.7"])
    else
      s.add_dependency(%q<parser>, ["~> 2.2.0.pre.7"])
      s.add_dependency(%q<procto>, ["~> 0.0.2"])
      s.add_dependency(%q<concord>, ["~> 0.1.5"])
      s.add_dependency(%q<adamantium>, ["~> 0.2.0"])
      s.add_dependency(%q<equalizer>, ["~> 0.0.9"])
      s.add_dependency(%q<abstract_type>, ["~> 0.0.7"])
    end
  else
    s.add_dependency(%q<parser>, ["~> 2.2.0.pre.7"])
    s.add_dependency(%q<procto>, ["~> 0.0.2"])
    s.add_dependency(%q<concord>, ["~> 0.1.5"])
    s.add_dependency(%q<adamantium>, ["~> 0.2.0"])
    s.add_dependency(%q<equalizer>, ["~> 0.0.9"])
    s.add_dependency(%q<abstract_type>, ["~> 0.0.7"])
  end
end
