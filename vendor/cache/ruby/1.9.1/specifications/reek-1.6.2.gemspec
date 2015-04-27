# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "reek"
  s.version = "1.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Rutherford", "Timo Roessner", "Matijs van Zuijlen"]
  s.date = "2015-01-13"
  s.description = "    Reek is a tool that examines Ruby classes, modules and methods and reports\n    any code smells it finds.\n"
  s.email = ["timo.roessner@googlemail.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["CHANGELOG", "License.txt"]
  s.files = ["bin/reek", "CHANGELOG", "License.txt"]
  s.homepage = "http://wiki.github.com/troessner/reek"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.md", "-x", "assets/|bin/|config/|features/|spec/|tasks/"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubyforge_project = "reek"
  s.rubygems_version = "1.8.23.2"
  s.summary = "Code smell detector for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parser>, ["~> 2.2.0.pre.7"])
      s.add_runtime_dependency(%q<unparser>, ["= 0.1.16"])
      s.add_runtime_dependency(%q<rainbow>, ["< 3.0", ">= 1.99"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.3"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<yard>, ["< 0.9", ">= 0.8.7"])
      s.add_development_dependency(%q<factory_girl>, ["~> 4.0"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.28.0"])
    else
      s.add_dependency(%q<parser>, ["~> 2.2.0.pre.7"])
      s.add_dependency(%q<unparser>, ["= 0.1.16"])
      s.add_dependency(%q<rainbow>, ["< 3.0", ">= 1.99"])
      s.add_dependency(%q<bundler>, ["~> 1.1"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<cucumber>, ["~> 1.3"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<yard>, ["< 0.9", ">= 0.8.7"])
      s.add_dependency(%q<factory_girl>, ["~> 4.0"])
      s.add_dependency(%q<rubocop>, ["~> 0.28.0"])
    end
  else
    s.add_dependency(%q<parser>, ["~> 2.2.0.pre.7"])
    s.add_dependency(%q<unparser>, ["= 0.1.16"])
    s.add_dependency(%q<rainbow>, ["< 3.0", ">= 1.99"])
    s.add_dependency(%q<bundler>, ["~> 1.1"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<cucumber>, ["~> 1.3"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<yard>, ["< 0.9", ">= 0.8.7"])
    s.add_dependency(%q<factory_girl>, ["~> 4.0"])
    s.add_dependency(%q<rubocop>, ["~> 0.28.0"])
  end
end
