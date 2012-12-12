import "default.pp"

class { 'rails-app':
  app_name => "registrations",
  domain => "agilebrazil.com",
}
