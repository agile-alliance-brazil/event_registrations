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

	package { 'libapache2-mod-passenger': 
		ensure => "present",
		require => Package['librack-ruby1.9.1'],
	}
}