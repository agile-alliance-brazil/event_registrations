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

  if $use_ssl {
    file { "/etc/apache2/mods-enabled/ssl.conf":
      ensure => "link",
      target => "/etc/apache2/mods-available/ssl.conf",
      require => Package["apache2"],
    }

    file { "/etc/apache2/mods-enabled/ssl.load":
      ensure => "link",
      target => "/etc/apache2/mods-available/ssl.load",
      require => Package["apache2"],
    }

    file { "self-signed.config":
      ensure => "present",
      path => "$path/../certs",
      source => "puppet:///modules/rails-app/self-signed.config"
    }

    exec { "generate-certificate":
      command => "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server_key.pem -out server.crt -config self-signed.config",
      path => "/usr/bin/",
      cwd => "$path/../../shared/certs",
      notify => Service['apache2'],
      require => [File['self-signed.config'],
                  File['/etc/apache2/mods-enabled/ssl.conf'],
                  File['/etc/apache2/mods-enabled/ssl.load']],
    }
  }
}