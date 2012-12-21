exec { 'update':
    command => "apt-get update",
    path => "/usr/bin",
}

class { 'web-server': }
class { 'db-server': }

$user = "ubuntu"
$app_name = "event_registrations"
$domain = "agilebrazil.com"
class { 'rails-app':
  user => $user,
  app_name => $app_name,
  domain => $domain,
}