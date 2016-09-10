#!/usr/bin/env bash
set -e
# set -x # Uncomment to debug

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${MY_DIR}

if [[ -z `which ruby` ]]; then
  echo "Missing ruby in your path. Please install the correct version and try again" && exit 1
fi

if [[ -z `which gem` ]]; then
  echo "Missing rubygems in your path. Please install the correct version and try again" && exit 1
fi

if [[ -z `which bundle` ]]; then
  echo "Installing bundler..."
  gem --version &> /dev/null && gem install bundler &> /dev/null
fi

OSX="false"
if [[ -n `uname -a | grep Darwin` ]]; then
  OSX="true"
fi

if [[ ${OSX} == "true" ]] && [[ -z `which brew` ]]; then
  echo "Installing brew. This will ask for your password..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [[ ${OSX} == "false" ]] && [[ -z `which apt-get` ]]; then
  echo "This setup is only ready for apt-get based linuxes and OSX. You'll have to open and edit this file to fix it for your distribution."
  exit 1
fi

if [[ -z `which mysqld` ]]; then
  echo "Installing mysql..."
  if [[ ${OSX} == "true" ]]; then
    (brew --version &> /dev/null && brew install mysql &> /dev/null && brew tap homebrew/services &> /dev/null)
  fi
  if [[ ${OSX} == "false" ]]; then
    (apt-get --version &> /dev/null && apt-get install -y mysql-server &> /dev/null)
  fi
fi

if [[ -z `ps xau | grep mysqld | grep -v grep` ]]; then
  echo "Starting mysqld..."
  if [[ ${OSX} == "true" ]]; then
    (brew --version &> /dev/null) && (brew services start mysql &> /dev/null)
  fi
  if [[ ${OSX} == "false" ]]; then
    service mysql start &> /dev/null
  fi
fi

if ! (echo 'SELECT USER();' | mysql -uregistrations_db -pregistrations_db &> /dev/null); then
  echo "Creating DB user registrations_db and granting permissions..."
  ROOT_MYSQL_COMMAND='mysql -uroot'
  while ! (echo 'SELECT USER();' | ${ROOT_MYSQL_COMMAND} &> /dev/null); do
    read -p "Please enter your mysql root password: " mysql_root_password
    ROOT_MYSQL_COMMAND="mysql -uroot -p$mysql_root_password"
  done

  (echo "CREATE USER \"registrations_db\"@\"localhost\" IDENTIFIED BY \"registrations_db\";" | ${ROOT_MYSQL_COMMAND}) || echo "User \"registrations_db\" already exists"
  echo "GRANT ALL PRIVILEGES ON *.* TO \"registrations_db\"@\"localhost\";" | ${ROOT_MYSQL_COMMAND}
  echo "FLUSH PRIVILEGES;" | ${ROOT_MYSQL_COMMAND}
fi

if [[ ! -f ${MY_DIR}/config/database.yml ]]; then
  echo "Creating default database.yml config. Please edit to match your needs..."
  cp ${MY_DIR}/config/database.{example,yml}
fi

if [[ ! -f ${MY_DIR}/config/config.yml ]]; then
  echo "Creating default config.yml config. Please edit to match your needs..."
  cp ${MY_DIR}/config/config.{example,yml}
fi

bundle install
