node default {
	exec { 'update':
	    command => "apt-get update",
	    path => "/usr/bin",
	}

	class { 'web-server': }
	class { 'db-server': }

  $app_name = "registrations"
  $domain = "agilebrazil.com"
  class { 'rails-app':
    app_name => $app_name,
    domain => $domain,
  }
}