# encoding: UTF-8
set :rails_env,           "production"
set :keep_releases,       1

set :user,                "vagrant"
# set :password,          "run vagrant ssh-config >> ~/.ssh/config before trying to deploy"

set :domain,              "default"
set :project,             "event_registrations"
set :application,         "event_registrations"
set :applicationdir,      "/srv/apps/#{application}"
set :bundle_cmd,          "/usr/local/bin/bundle"
set :rake,                "#{bundle_cmd} exec rake"

set :scm,                 :git
set :repository,          "git@github.com:hugocorbucci/event_registrations.git"
set :scm_verbose,         true

set :deploy_to,           applicationdir
set :deploy_via,          :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :use_sudo, false
