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

  file { '/etc/apache2/mods-enabled/passenger.load':
    source => 'passenger.load',
    require => Class['apache'],
  }

  file { '/etc/apache2/mods-enabled/passenger.conf':
    source => 'passenger.conf',
    require => Class['apache'],
  }
}