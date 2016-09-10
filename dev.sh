#!/usr/bin/env bash
set -e
# set -x # Uncomment to debug

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${MY_DIR}

${MY_DIR}/setup.sh

if [[ ! -f ${MY_DIR}/.env ]]; then
  echo "Copying example .env file. Please edit for your needs..."
  cp ${MY_DIR}/.env{.example,}
fi

if [[ -z `cat ${MY_DIR}/.env | grep PORT` ]]; then
  printf "\nPORT=9292\n" >> ${MY_DIR}/.env
fi

if [[ -z `cat ${MY_DIR}/.env | grep PORT` ]]; then
  printf "\nTOKEN=`bundle exec rake secret`\n" >> ${MY_DIR}/.env
fi

bundle exec rake db:create db:migrate
RAILS_ENV=test bundle exec rake db:create db:migrate
bundle exec foreman start -f Procfile.dev
