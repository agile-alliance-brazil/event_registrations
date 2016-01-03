node default {
  include stdlib

  exec { 'update':
    command => 'apt-get update',
    path => '/usr/bin',
  }

  package { 'git-core':
    ensure => 'present',
  }

  package { 'sqlite3':
    ensure => 'present',
  }

  package { 'libsqlite3-dev':
    ensure => 'present',
    require => Package['sqlite3'],
  }

  #required for mysql2 gem
  package { 'libmysqlclient-dev':
    ensure => 'present',
  }

  $user = "vagrant"

  class { 'railsapp':
    user => $user,
    app_name => 'registrations',
  }

  class { 'swap':
    swapsize => to_bytes('1 MB'),
  }

  package { 'xvfb':
    ensure => 'installed',
  }

  package { 'phantomjs':
    ensure => 'installed',
    require => Package['xvfb'],
  }
}
