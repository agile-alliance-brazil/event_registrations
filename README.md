# Event Registrations [![Build Status](https://snap-ci.com/agile-alliance-brazil/event_registrations/branch/master/build_image)](https://snap-ci.com/agile-alliance-brazil/event_registrations/branch/master) [![Dependency Status](https://gemnasium.com/agile-alliance-brazil/event_registrations.svg)](https://gemnasium.com/agile-alliance-brazil/event_registrations) [![Code Climate](https://codeclimate.com/github/agile-alliance-brazil/event_registrations/badges/gpa.svg)](https://codeclimate.com/github/agile-alliance-brazil/event_registrations) [![Test Coverage](https://codeclimate.com/github/agile-alliance-brazil/event_registrations/badges/coverage.svg)](https://codeclimate.com/github/agile-alliance-brazil/event_registrations)
===================

An app to handle event registrations. Intended to be lightweight and rest queriable to allow integration with third party systems.

Feature requests, bug reports and questions are to be sent to GitHub's issue system: [https://github.com/agile-alliance-brazil/event_registrations/issues](https://github.com/agile-alliance-brazil/event_registrations/issues)

# Development

Just clone this repo, enter it and run `./dev.sh`. This should be enough to install whatever is needed on your machine and start guard to run specs and front end tests.

If you don't want to mess with your own machine, an option to use [Vagrant](https://www.vagrantup.com/) for development is available. Download [Vagrant 1.8.1](https://releases.hashicorp.com/vagrant/1.8.1/) and [Virtual Box](https://www.virtualbox.org/wiki/Downloads), install both and then run:

```sh
vagrant destroy -f dev && vagrant up dev && vagrant ssh dev
````

Once inside the vagrant box, run `/srv/apps/registrations/current/dev.sh`. Note that the code will be sync'ed between the virtual machine and your machine so you can still use your favorite editor and handle version control from your machine if you prefer.

## Deployment

Provisioning is handled by [Puppet](https://puppetlabs.com/) [4.3.1](http://docs.puppetlabs.com/puppet/latest/reference/install_pre.html). It can be tested with [Vagrant](https://www.vagrantup.com/) [1.8.1](https://releases.hashicorp.com/vagrant/1.8.1/).

Deployment is handled by [Capistrano](http://capistranorb.com/). And can also be tested using the vagrant set up.

To test, run:
```sh
vagrant destroy -f deploy && vagrant up deploy && bundle exec ruby script/first\_deploy.rb vagrant 127.0.0.1:2203 certs/insecure\_private\_key
```

Note that Capistrano uses the code currently available in github so you need to push to test it.
You can set up `config/deploy/127.0.0.1.rb` to use a different branch with `set :branch, 'your_branch'`.

### Deploying to a cloud

If you're deploying to any cloud, after you've created your virtual machine, add `config/<vms_ip>_config.yml`, `config/<vms_ip>_database.yml`, `certs/<vms_ip>_app_key.pem`, `certs/<vms_ip>_app_cert.pem` and `certs/<vms_ip>_paypal_cert.pem`. You can, optionally, also add `certs/<vms_ip>_server.crt`, `certs/<vms_ip>_server_key.pem` and `certs/<vms_ip>_server_key.pem` to set up apache to work with SSL. Then run:
```sh
bundle exec ruby script/first_deploy.rb <configured_sudoer_user> <vms_ip> <ssh_key_to_access_vm>
```

#### Digital Ocean

If you're deploying to [Digital Ocean](https://www.digitalocean.com/?refcode=f3805af8abc0) specifically, go to your [API settings](https://cloud.digitalocean.com/settings/applications), request a Personal Access Token, save it and run:
```sh
export TOKEN=<your_token>
```

From then on, you can use:
```sh
bundle exec ruby deploy/digital_ocean/new_machine.rb
```

# Feedback

If you have a bug or a feature request, please create a issue here:

[https://github.com/agile-alliance-brazil/event_registrations/issues](https://github.com/agile-alliance-brazil/event_registrations/issues)

# Team

Thanks to everyone involved in building and maintaining this system:

* [Celso Martins](https://github.com/celsoMartins) (Core Developer)
* [Hugo Corbucci](https://hugocorbucci.com) (Core Developer)
* [Danilo Sato](http://www.dtsato.com) (Collaborator)
