class db-server {
	include mysql

	package { 'libmysql-ruby1.9.1': 
		require => Package['ruby1.9.3'],
	}
}