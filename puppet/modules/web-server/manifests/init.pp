class web-server { 
	include passenger-apache

	package { "git-core":
	  ensure => "present",
	}
}