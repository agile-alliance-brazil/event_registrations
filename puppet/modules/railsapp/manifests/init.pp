class railsapp( $user, $app_name ) {
  class { '::rvm': }

  if $rvm_installed == true {
    rvm::system_user { $user:; }

    rvm_system_ruby { 'ruby-2.4.3':
        name        => 'ruby-2.4.3',
        ensure      => 'present',
        build_opts  => '--disable-binary',
        default_use => false
    }
    rvm_system_ruby { 'ruby-2.6.4':
        name        => 'ruby-2.6.4',
        ensure      => 'present',
        build_opts  => '--disable-binary',
        default_use => true
    }

    rvm_gem { 'bundler243':
        name         => 'bundler',
        ruby_version => 'ruby-2.4.3@global',
        ensure       => '1.16.6',
        require      => Rvm_system_ruby['ruby-2.4.3'];
    }

    rvm_gem { 'rubygemsupdate308':
        name         => 'rubygems-update',
        ruby_version => 'ruby-2.6.4@global',
        ensure       => '3.0.8',
        source       => "https://rubygems.org/",
        require      => Rvm_system_ruby['ruby-2.6.4'];
    }

    rvm_gem { 'bundler264':
        name         => 'bundler',
        ruby_version => 'ruby-2.6.4@global',
        ensure       => '1.17.3',
        source       => "https://rubygems.org/",
        require      => Rvm_gem['rubygemsupdate308'];
    }
  }

  file { "/srv":
    ensure => "directory",
  }

  file { "/srv/apps":
    ensure => "directory",
    require => File["/srv"],
  }

  file { "/srv/apps/$app_name":
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps"],
  }

  file { "/srv/apps/$app_name/shared":
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps/$app_name"],
  }

  file { "config_folder":
    path => "/srv/apps/$app_name/shared/config",
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps/$app_name/shared"],
  }

  file { "certs_folder":
    path => "/srv/apps/$app_name/shared/certs",
    ensure => "directory",
    owner => $user,
    require => File["/srv/apps/$app_name/shared"],
  }

  if $use_ssl {
    file { "self-signed.config":
      ensure => "present",
      path => "/srv/apps/$app_name/shared/certs/self-signed.config",
      source => "puppet:///modules/railsapp/self-signed.config",
      require => File["/srv/apps/$app_name/shared"],
    }

    exec { "generate-certificate":
      command => "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server_key.pem -out server.crt -config self-signed.config",
      path => "/usr/bin/",
      cwd => "/srv/apps/$app_name/shared/certs",
      notify => Service['apache2'],
      require => File['self-signed.config'],
      creates => "/srv/apps/$app_name/shared/certs/server.crt",
    }
  }

  # required for asset pipeline
  package { 'java':
    ensure => "installed",
    name => "openjdk-11-jre-headless",
    require => Exec["update"],
  }

  # required for rvm
  package { 'gnupg2':
    ensure => "installed",
    require => Exec["update"],
  }

  # required for paperclip
  package { "imagemagick":
    ensure => "installed",
    require => Exec["update"]
  }
}
