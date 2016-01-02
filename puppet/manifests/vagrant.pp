node default {
  include stdlib

  exec { 'update':
    command => "apt-get update",
    path => "/usr/bin",
  }

  $app_name = "registrations"

  class { 'swap':
    swapsize => to_bytes('1 MB'),
  }
  class { 'webserver':
    server_url => $server_url
  }
  class { 'dbserver':
    app_name => $app_name
  }

  class { 'railsapp':
    user => "vagrant",
    app_name => $app_name,
  }
}
