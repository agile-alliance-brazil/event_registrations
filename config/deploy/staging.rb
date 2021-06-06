# frozen_string_literal: true

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
server 'inscricoes-staging.agilebrazil.com', user: 'ubuntu', roles: %w[web app db]
set :manifest, 'default'
set :server_url, 'inscricoes-staging.agilebrazil.com'

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
set :ssh_options, {
  keys: [
    File.join(File.dirname(__FILE__), '../../certs/digital_ocean_staging'),
    File.expand_path('~/.ssh/id_inscricoes-staging.agilebrazil.com')
  ],
  forward_agent: true,
  auth_methods: %w[publickey]
  # password: 'please use keys'
}

host = 'https://event-registrations-staging.herokuapp.com/'
config.action_mailer.default_url_options = { host: host }
config.action_mailer.asset_host = host
