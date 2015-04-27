# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "roodi"
  s.version = "3.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marty Andrews", "Peter Evjan"]
  s.date = "2013-11-09"
  s.description = "Roodi parses your Ruby code and warns you about design issues you have based on the checks that is has configured"
  s.email = "hello@peterevjan.com"
  s.executables = ["roodi", "roodi-describe"]
  s.files = ["bin/roodi", "bin/roodi-describe"]
  s.homepage = "http://github.com/roodi/roodi"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Roodi stands for Ruby Object Oriented Design Inferometer"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby_parser>, [">= 3.2.2", "~> 3.2"])
    else
      s.add_dependency(%q<ruby_parser>, [">= 3.2.2", "~> 3.2"])
    end
  else
    s.add_dependency(%q<ruby_parser>, [">= 3.2.2", "~> 3.2"])
  end
end
