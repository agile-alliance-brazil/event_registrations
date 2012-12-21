node default {
	exec { 'update':
	    command => "apt-get update",
	    path => "/usr/bin",
	}

	class { 'web-server': }
	class { 'db-server': }

  $app_name = "event_registrations"
  $domain = "agilebrazil.com"
  $user = "ubuntu"
  class { 'rails-app':
    user => $user,
    app_name => $app_name,
    domain => $domain,
  }
}