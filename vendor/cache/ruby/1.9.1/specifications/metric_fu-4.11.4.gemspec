# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "metric_fu"
  s.version = "4.11.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jake Scruggs", "Sean Soper", "Andre Arko", "Petrik de Heus", "Grant McInnes", "Nick Quaranto", "\u{c9}douard Bri\u{e8}re", "Carl Youngblood", "Richard Huang", "Dan Mayer", "Benjamin Fleischer", "Robin Curry"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDmjCCAoKgAwIBAgIBATANBgkqhkiG9w0BAQUFADBJMQ8wDQYDVQQDDAZnaXRo\ndWIxITAfBgoJkiaJk/IsZAEZFhFiZW5qYW1pbmZsZWlzY2hlcjETMBEGCgmSJomT\n8ixkARkWA2NvbTAeFw0xNTAxMjIxMzAyNTNaFw0xNjAxMjIxMzAyNTNaMEkxDzAN\nBgNVBAMMBmdpdGh1YjEhMB8GCgmSJomT8ixkARkWEWJlbmphbWluZmxlaXNjaGVy\nMRMwEQYKCZImiZPyLGQBGRYDY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB\nCgKCAQEA7V1VZBU7Aft01XAoK8I8tdClfv3H/NIauiV0jfyNtXtZEWwaZ6ooZNLk\n8kmIUsO2xI7I/B3es6w7le9q9xdEowlYjiR/X/yazNvufu5kpM4f6Ri1AKN8xvPk\nLFlR8aOAd9LptcusYDfE+BjhmAvnLTgMGODcDLJIaJzLJaRywTLUuFv4digpFwCm\nZps9VheJnL4hkgI5BDn6DVjxHSCMRnccQM/kX9L34lbP9KkHXXEtQgkQYpElHbnd\nMtR753aPeLfOBxSGzsso+6Lhe+fz8huD05mzgWaEZN40e6M7dA9FRSsEzL32ZOad\n0z13MZWj3Yg5srV/cZvzCDCdVvRphwIDAQABo4GMMIGJMAkGA1UdEwQCMAAwCwYD\nVR0PBAQDAgSwMB0GA1UdDgQWBBQvUrPExdvmdz0Vau0dH3hRh1YQfDAnBgNVHREE\nIDAegRxnaXRodWJAYmVuamFtaW5mbGVpc2NoZXIuY29tMCcGA1UdEgQgMB6BHGdp\ndGh1YkBiZW5qYW1pbmZsZWlzY2hlci5jb20wDQYJKoZIhvcNAQEFBQADggEBAEWo\ng1soMaRTT/OfFklTuP+odV0w+2qJSfJhOY5bIebDjqxb9BN7hZJ9L6WXhcXCvl6r\nkuXjpcC05TIv1DoWWaSjGK2ADmEBDNVhaFepYidAYuUQN4+ZjVH/gS9V9OkBcE8h\n3ZwRv+9RkXM0uY1FwuGI6jgbgPeR1AkkfJnhOPohkG+VN5bFo9aK/Stw8Nwhuuiz\naxCPD3cmaJBguufRXSMC852SDiBT7AtI4Gl2Fyr+0M5TzXHKbQ9xRBxwfE1bWDd6\nlEs7ndJ1/vd/Hy0zQ1tIRWyql+ITLhqMi161Pw5flsYpQvPlRLR5pGJ4eD0/JdKE\nZG9WSFH7QcGLY65mEYc=\n-----END CERTIFICATE-----\n"]
  s.date = "2015-02-27"
  s.description = "Code metrics from Flog, Flay, Saikuro, Churn, Reek, Roodi, Code Statistics, and Rails Best Practices. (and optionally RCov)"
  s.email = "github@benjaminfleischer.com"
  s.executables = ["metric_fu", "mf-cane", "mf-churn", "mf-flay", "mf-reek", "mf-roodi", "mf-saikuro"]
  s.extra_rdoc_files = ["HISTORY.md", "CONTRIBUTING.md", "TODO.md", "MIT-LICENSE"]
  s.files = ["bin/metric_fu", "bin/mf-cane", "bin/mf-churn", "bin/mf-flay", "bin/mf-reek", "bin/mf-roodi", "bin/mf-saikuro", "HISTORY.md", "CONTRIBUTING.md", "TODO.md", "MIT-LICENSE"]
  s.homepage = "https://github.com/metricfu/metric_fu"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.0")
  s.rubyforge_project = "metric_fu"
  s.rubygems_version = "1.8.23.2"
  s.summary = "A fistful of code metrics, with awesome templates and graphs"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<flay>, [">= 2.0.1", "~> 2.1"])
      s.add_runtime_dependency(%q<churn>, ["~> 0.0.35"])
      s.add_runtime_dependency(%q<flog>, [">= 4.1.1", "~> 4.1"])
      s.add_runtime_dependency(%q<reek>, [">= 1.3.4", "~> 1.3"])
      s.add_runtime_dependency(%q<cane>, [">= 2.5.2", "~> 2.5"])
      s.add_runtime_dependency(%q<rails_best_practices>, [">= 1.14.3", "~> 1.14"])
      s.add_runtime_dependency(%q<metric_fu-Saikuro>, [">= 1.1.3", "~> 1.1"])
      s.add_runtime_dependency(%q<roodi>, ["~> 3.1"])
      s.add_runtime_dependency(%q<code_metrics>, ["~> 0.1"])
      s.add_runtime_dependency(%q<redcard>, [">= 0"])
      s.add_runtime_dependency(%q<coderay>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<launchy>, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<test_construct>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.9"])
    else
      s.add_dependency(%q<flay>, [">= 2.0.1", "~> 2.1"])
      s.add_dependency(%q<churn>, ["~> 0.0.35"])
      s.add_dependency(%q<flog>, [">= 4.1.1", "~> 4.1"])
      s.add_dependency(%q<reek>, [">= 1.3.4", "~> 1.3"])
      s.add_dependency(%q<cane>, [">= 2.5.2", "~> 2.5"])
      s.add_dependency(%q<rails_best_practices>, [">= 1.14.3", "~> 1.14"])
      s.add_dependency(%q<metric_fu-Saikuro>, [">= 1.1.3", "~> 1.1"])
      s.add_dependency(%q<roodi>, ["~> 3.1"])
      s.add_dependency(%q<code_metrics>, ["~> 0.1"])
      s.add_dependency(%q<redcard>, [">= 0"])
      s.add_dependency(%q<coderay>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<launchy>, ["~> 2.0"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<test_construct>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<simplecov>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<flay>, [">= 2.0.1", "~> 2.1"])
    s.add_dependency(%q<churn>, ["~> 0.0.35"])
    s.add_dependency(%q<flog>, [">= 4.1.1", "~> 4.1"])
    s.add_dependency(%q<reek>, [">= 1.3.4", "~> 1.3"])
    s.add_dependency(%q<cane>, [">= 2.5.2", "~> 2.5"])
    s.add_dependency(%q<rails_best_practices>, [">= 1.14.3", "~> 1.14"])
    s.add_dependency(%q<metric_fu-Saikuro>, [">= 1.1.3", "~> 1.1"])
    s.add_dependency(%q<roodi>, ["~> 3.1"])
    s.add_dependency(%q<code_metrics>, ["~> 0.1"])
    s.add_dependency(%q<redcard>, [">= 0"])
    s.add_dependency(%q<coderay>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<launchy>, ["~> 2.0"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<test_construct>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<simplecov>, ["~> 0.9"])
  end
end
