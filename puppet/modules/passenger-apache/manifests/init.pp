class passenger-apache {
	include apache

	package { 'librack-ruby1.9.1': 
		ensure => "present",
		require => Package["ruby1.9.3"],
	}

	package { 'libapache2-mod-passenger': 
		ensure => "present",
		require => Package['librack-ruby1.9.1'],
	}
}