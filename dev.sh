#!/usr/bin/env bash
(gem > /dev/null && gem install bundler > /dev/null)
(brew --version &> /dev/null) && (brew install mysql &> /dev/null) && (brew tap homebrew/services &> /dev/null) && (brew services start mysql &> /dev/null)
(apt-get --version &> /dev/null) && (apt-get install -y mysql-server &> /dev/null) && (service mysql start &> /dev/null)
echo "GRANT ALL PRIVILEGES ON * . * TO 'registrations_db'@'localhost';" | mysql -u root
bundle install --path=vendor/bundle
bundle exec foreman start -f Procfile.dev
