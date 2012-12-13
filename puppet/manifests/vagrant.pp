import "default.pp"

$app_name = "registrations"
$domain = "agilebrazil.com"
class { 'rails-app':
  app_name => $app_name,
  domain => $domain,
}
