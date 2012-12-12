class rails-app( $app_name, $domain ) {
	class { "rails-app::db":
		app_name => "$app_name",
		password => "53cr3T",
	}

	package { "ruby1.9.3":
		ensure => "installed",
		require => Exec["update"],
	}

	exec { "update-gem-sources":
		command => "gem sources -u",
		path => "/usr/bin",
		require => Package["ruby1.9.3"],
	}

	package { "bundler":
		provider => "gem",
		ensure => "1.2.3",
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
		owner => "vagrant",
		require => File["/srv/apps"]
	}

	file { "/srv/apps/$app_name/shared":
		ensure => "directory",
		owner => "vagrant",
		require => File["/srv/apps/$app_name"]
	}

	file { "config_folder":
		path => "/srv/apps/$app_name/shared/config",
		ensure => "directory",
		owner => "vagrant",
		require => File["/srv/apps/$app_name/shared"]
	}

    # required for asset pipeline
	package { 'java':
		ensure => "installed",
		name => "openjdk-6-jre-headless",
		require => Exec["update"],
	}

	class { "rails-app::passenger":
		path => "/srv/apps/$app_name/current/public",
		server_name => "$app_name.$domain",
	}
}