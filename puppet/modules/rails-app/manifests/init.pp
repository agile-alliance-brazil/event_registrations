class rails-app( $user, $app_name, $domain ) {
	package { "build-essential":
		ensure => "installed",
		require => Exec["update"],
	}

	package { "ruby1.9.1":
		ensure => "installed",
		require => Exec["update"],
	}

	exec { "update-gem-sources":
		command => "gem sources -u",
		path => "/usr/bin",
		require => Package["ruby1.9.1"],
	}

	package { "bundler":
		provider => "gem",
		ensure => "1.2.4",
		require => Exec["update-gem-sources"]
	}

	file { "/srv":
		ensure => "directory",
	}

	file { "/srv/apps":
		ensure => "directory",
		require => File["/srv"]
	}

	file { "/srv/apps/$app_name":
		ensure => "directory",
		owner => $user,
		require => File["/srv/apps"]
	}

	file { "/srv/apps/$app_name/shared":
		ensure => "directory",
		owner => $user,
		require => File["/srv/apps/$app_name"]
	}

	file { "config_folder":
		path => "/srv/apps/$app_name/shared/config",
		ensure => "directory",
		owner => $user,
		require => File["/srv/apps/$app_name/shared"]
	}

  # required for asset pipeline
	package { 'java':
		ensure => "installed",
		name => "openjdk-6-jre-headless",
		require => Exec["update"],
	}
}