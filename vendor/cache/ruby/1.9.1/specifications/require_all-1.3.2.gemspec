# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "require_all"
  s.version = "1.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jarmo Pertman", "Tony Arcieri"]
  s.date = "2013-10-30"
  s.email = "jarmo.p@gmail.com"
  s.extra_rdoc_files = ["LICENSE", "README.md", "CHANGES"]
  s.files = ["LICENSE", "README.md", "CHANGES"]
  s.homepage = "http://github.com/jarmo/require_all"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--title", "require_all", "--main", "README.md", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "A wonderfully simple way to load your code"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7"])
    else
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rspec>, ["~> 2.14"])
      s.add_dependency(%q<simplecov>, ["~> 0.7"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rspec>, ["~> 2.14"])
    s.add_dependency(%q<simplecov>, ["~> 0.7"])
  end
end
