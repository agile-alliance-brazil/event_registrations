class webserver($server_url = "$app_name.$domain") {
	package { "git-core":
	  ensure => "present",
	}
	
	class { "railsapp::passenger":
		path => "/srv/apps/$app_name/current/public",
		server_url => $server_url,
	}
}