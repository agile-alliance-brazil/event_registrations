node default {
	exec { 'update':
	    command => "apt-get update",
	    path => "/usr/bin",
	}

	class { 'web-server': }
	class { 'db-server': }
}