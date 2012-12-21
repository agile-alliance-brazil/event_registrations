exec { 'update':
    command => "apt-get update",
    path => "/usr/bin",
}

$app_name = "registrations"

class { 'web-server': }
class { 'db-server': 
  app_name => $app_name
}

class { 'rails-app':
  app_name => $app_name,
  domain => "agilebrazil.com",
}