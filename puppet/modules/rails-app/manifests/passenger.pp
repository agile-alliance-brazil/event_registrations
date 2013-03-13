class rails-app::passenger ($path = '/srv/apps/rails-app/current/public', $server_name) {
	file { "/etc/apache2/sites-available/$server_name":
		ensure => "present",
		content => template("rails-app/passenger-app.erb"),
		require => Package["apache2"],
	}

	file { "/etc/apache2/sites-enabled/000-default":
		ensure => "/etc/apache2/sites-available/$server_name",
		require => File["/etc/apache2/sites-available/$server_name"],
	}

  file { "/etc/apache2/mods-enabled/ssl.conf":
    ensure => "/etc/apache2/mods-available/ssl.conf",
    require => File["/etc/apache2/mods-available/ssl.conf"],
  }

  file { "/etc/apache2/mods-enabled/ssl.load":
    ensure => "/etc/apache2/mods-available/ssl.load",
    require => File["/etc/apache2/mods-available/ssl.load"],
  }
}