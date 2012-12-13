node default {
	exec { 'update':
	    command => "apt-get update",
	    path => "/usr/bin",
	}

	package { "git-core":
	  ensure => "present",
	}

	package { "sqlite3":
	  ensure => "present",
	}

	package { "libsqlite3-dev":
	  ensure => "present",
	  require => Package["sqlite3"],
	}

	class { 'rails-app':
	  app_name => "registrations",
	  domain => "agilebrazil.com",
	}

	exec { 'bundle install':
		path => "/usr/local/bin",
		cwd => "/srv/apps/registrations/current",
		require => [Class['rails-app'], Package['sqlite3']]
	}

	exec { 'rails server -p 9292 &':
		path => "/srv/apps/registrations/current/script",
		cwd => "/srv/apps/registrations/current",
		require => Exec['bundle install']
	}
}