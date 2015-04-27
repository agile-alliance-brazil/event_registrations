# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "astrolabe"
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yuji Nakayama"]
  s.date = "2014-08-22"
  s.description = "An object-oriented AST extension for Parser"
  s.email = ["nkymyj@gmail.com"]
  s.homepage = "https://github.com/yujinakayama/astrolabe"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "An object-oriented AST extension for Parser"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parser>, ["< 3.0", ">= 2.2.0.pre.3"])
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<rake>, ["~> 10.3"])
      s.add_development_dependency(%q<yard>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<fuubar>, ["~> 2.0.0.rc1"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.24"])
      s.add_development_dependency(%q<guard-rspec>, ["< 5.0", ">= 4.2.3"])
      s.add_development_dependency(%q<guard-rubocop>, ["~> 1.0"])
      s.add_development_dependency(%q<ruby_gntp>, ["~> 0.3"])
    else
      s.add_dependency(%q<parser>, ["< 3.0", ">= 2.2.0.pre.3"])
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<rake>, ["~> 10.3"])
      s.add_dependency(%q<yard>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<fuubar>, ["~> 2.0.0.rc1"])
      s.add_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_dependency(%q<rubocop>, ["~> 0.24"])
      s.add_dependency(%q<guard-rspec>, ["< 5.0", ">= 4.2.3"])
      s.add_dependency(%q<guard-rubocop>, ["~> 1.0"])
      s.add_dependency(%q<ruby_gntp>, ["~> 0.3"])
    end
  else
    s.add_dependency(%q<parser>, ["< 3.0", ">= 2.2.0.pre.3"])
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<rake>, ["~> 10.3"])
    s.add_dependency(%q<yard>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<fuubar>, ["~> 2.0.0.rc1"])
    s.add_dependency(%q<simplecov>, ["~> 0.7"])
    s.add_dependency(%q<rubocop>, ["~> 0.24"])
    s.add_dependency(%q<guard-rspec>, ["< 5.0", ">= 4.2.3"])
    s.add_dependency(%q<guard-rubocop>, ["~> 1.0"])
    s.add_dependency(%q<ruby_gntp>, ["~> 0.3"])
  end
end
