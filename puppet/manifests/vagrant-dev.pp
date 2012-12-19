node default {
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

	package { 'libmysql-ruby1.9.1': 
		ensure => 'present',
		require => Package['ruby1.9.3'],
	}

	#required for mysql2 gem
	package { 'libmysqlclient-dev':
		ensure => 'present',
	}

	class { 'rails-app':
	  app_name => 'registrations',
	  domain => 'agilebrazil.com',
	}

	exec { 'bundle install':
		path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
		command => 'bundle install --path vendor/bundle',
		cwd => '/srv/apps/registrations/current',
		user => 'vagrant',
		logoutput => true,
		require => [Class['rails-app'], Package['sqlite3'], Package['libmysql-ruby1.9.1'], Package['libmysqlclient-dev'], Package['git-core']]
	}

	service { 'rails server':
		ensure => 'running',
		hasrestart => false,
		hasstatus => false,
		provider => 'base',
		start => '/usr/bin/ruby1.9.3 /srv/apps/registrations/current/script/rails server -p 9292 &',
		stop => '/usr/bin/pkill ruby1.9.3',
	}

	Exec['bundle install'] -> Service['rails server']
}