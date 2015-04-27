# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/konacha-rails/version'

Gem::Specification.new do |s|
  s.name        = 'guard-konacha-rails'
  s.version     = Guard::KonachaRailsVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Leonid Beder']
  s.email       = ['leonid.beder@gmail.com']
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/lbeder/guard-konacha-rails'
  s.summary     = 'Guard plugin for the konacha testing framework'
  s.description = 'Guard plugin for the konacha testing framework.'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'guard', '>= 2'
  s.add_dependency 'rails', '>= 4.0'
  s.add_dependency 'konacha', '>= 3.0'
  s.add_dependency 'guard-compat'

  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'poltergeist'
end
