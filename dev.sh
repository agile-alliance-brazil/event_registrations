#!/usr/bin/env bash
set -e

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

if [[ -z `ps xau | grep mysqld` ]]; then
  echo "Starting mysqld..."
  if [[ ${OSX} == "true" ]]; then
    (brew --version &> /dev/null) && (brew services start mysql &> /dev/null)
  fi
  if [[ ${OSX} == "false" ]]; then
    service mysql start &> /dev/null
  fi
fi

echo "GRANT ALL PRIVILEGES ON * . * TO 'registrations_db'@'localhost';" | mysql -u root

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${MY_DIR}

bundle install

if [[ ! -f ${MY_DIR}/.env ]]; then
  printf "TOKEN=`bundle exec rake secret`\n" > ${MY_DIR}/.env
fi

if [[ -z `cat ${MY_DIR}/.env | grep PORT` ]]; then
  printf "PORT=9292\n" >> ${MY_DIR}/.env
fi

bundle exec foreman start -f Procfile.dev
