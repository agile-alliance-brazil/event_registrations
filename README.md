# Event Registrations 
[![Build Status](https://circleci.com/gh/agile-alliance-brazil/event_registrations.svg?style=svg)](https://circleci.com/gh/agile-alliance-brazil/event_registrations) [![Code Climate](https://codeclimate.com/github/agile-alliance-brazil/event_registrations/badges/gpa.svg)](https://codeclimate.com/github/agile-alliance-brazil/event_registrations) [![Test Coverage](https://codeclimate.com/github/agile-alliance-brazil/event_registrations/badges/coverage.svg)](https://codeclimate.com/github/agile-alliance-brazil/event_registrations) [![security](https://hakiri.io/github/agile-alliance-brazil/event_registrations/master.svg)](https://hakiri.io/github/agile-alliance-brazil/event_registrations/master)
===================

An app to handle event registrations. Intended to be lightweight and rest queriable to allow integration with third party systems.

Feature requests, bug reports and questions are to be sent to GitHub's issue system: [https://github.com/agile-alliance-brazil/event_registrations/issues](https://github.com/agile-alliance-brazil/event_registrations/issues)

# Development

Just clone this repo (including submodules so ensure you run `git clone https://github.com/agilealliancebrazil/event_registrations.git  --recursive` or if you already cloned, use `git submodule foreach git pull origin master`), enter it and run `./dev.sh`. This should be enough to install whatever is needed on your machine and start guard to run specs and front end tests.

If you don't want to mess with your own machine, an option to use [Docker](https://www.docker.com/) for development is available.

```sh
docker-compose build
````

For populating the db and configuration for the first time:

```sh
cp config/config.example config/config.yml
cp config/database.docker config/database.yml
docker-compose up -d db
docker-compose run app bundle exec rake db:create db:schema:load --trace
````

For running the application:

```sh
docker-compose up
````

The application will be available at http://localhost:3000

## Deployment

Images are handled by ImageMagick and you must have it installed in your environment: https://www.imagemagick.org/

Provisioning is handled by [Puppet](https://puppetlabs.com/) [4.3.1](http://docs.puppetlabs.com/puppet/latest/reference/install_pre.html). It can be tested with [Vagrant](https://www.vagrantup.com/) [1.8.1](https://releases.hashicorp.com/vagrant/1.8.1/).

Deployment is handled by [Capistrano](http://capistranorb.com/). And can also be tested using the vagrant set up.

To test, run:
```sh
vagrant destroy -f deploy && vagrant up deploy && bundle && bundle exec ruby script/first_deploy.rb vagrant 10.11.12.14 staging certs/insecure_private_key
```

Note that Capistrano uses the code currently available in github so you need to push to test it.
You can set up `config/deploy/vagrant.rb` to use a different branch with `set :branch, 'your_branch'`.

### Deploying to a cloud

If you're deploying to any cloud, after you've created your virtual machine, add `config/<vms_ip>_config.yml`, `config/<vms_ip>_database.yml`, `certs/<vms_ip>_app_key.pem`, `certs/<vms_ip>_app_cert.pem` and `certs/<vms_ip>_paypal_cert.pem`. You can, optionally, also add `certs/<vms_ip>_server.crt`, `certs/<vms_ip>_server_key.pem` and `certs/<vms_ip>_server_key.pem` to set up apache to work with SSL. Then run:
```sh
bundle && bundle exec ruby script/first_deploy.rb <configured_sudoer_user> <vms_ip> <type> <ssh_key_to_access_vm>
```
Where your sudoer user is a user in that machine that has sudo right (no password required), vms_ip is the vm IPv4 addres, type is either 'production' or 'staging' and the ssh key is the path in your machine to the ssh key that allows non password protected access to your cloud VM.

#### Digital Ocean

If you're deploying to [Digital Ocean](https://www.digitalocean.com/?refcode=f3805af8abc0) specifically, go to your [API settings](https://cloud.digitalocean.com/settings/applications), request a Personal Access Token, save it and run:
```sh
export TOKEN=<your_token>
```

From then on, you can use:
```sh
bundle && bundle exec ruby deploy/digital_ocean/new_machine.rb
```

#### Integration service bus for Agile Alliance membership checking
* [github](https://github.com/agile-alliance-brazil/aa-service-bus)
* [heroku](https://aa-service-bus.herokuapp.com/)

# Feedback

If you have a bug or a feature request, please create a issue here:

[https://github.com/agile-alliance-brazil/event_registrations/issues](https://github.com/agile-alliance-brazil/event_registrations/issues)

# Team

Thanks to everyone involved in building and maintaining this system:

* [Celso Martins](https://github.com/celsoMartins) (Core Developer)
* [Hugo Corbucci](https://hugocorbucci.com) (Core Developer)
* [Danilo Sato](http://www.dtsato.com) (Collaborator)
