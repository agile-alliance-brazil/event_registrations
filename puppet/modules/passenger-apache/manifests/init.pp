class passenger-apache {
	include apache

	package { 'librack-ruby1.9.1': 
		ensure => "present",
		require => Package["ruby1.9.1"],
	}

  package { 'libcurl4-openssl-dev':
    ensure => "installed",
    require => Exec["update"],
  }

	package { 'passenger': 
		ensure => "3.0.19",
    provider => "gem",
		require => Package['librack-ruby1.9.1'],
	}

  exec { "passenger-install-apache2-module":
    command => "passenger-install-apache2-module --auto",
    path => "/usr/local/bin/",
    refreshonly => true,
    subscribe => Package['passenger'],
  }

  file { '/etc/apache2/mods-enabled/passenger.load':
    source => 'puppet://modules/passenger-apache/passenger.load',
    require => Class['apache'],
  }

  file { '/etc/apache2/mods-enabled/passenger.conf':
    source => 'puppet://modules/passenger-apache/passenger.conf',
    require => Class['apache'],
  }
}