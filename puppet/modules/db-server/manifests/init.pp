class db-server {
	include mysql

	package { 'libmysql-ruby1.9.1': 
		require => Package['ruby1.9.1'],
	}
	
	class { "rails-app::db":
		app_name => "$app_name",
		password => "53cr3T",
	}
}