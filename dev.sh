#!/usr/bin/env bash
(gem > /dev/null && gem install bundler > /dev/null)
bundle install --path=vendor/bundle
bundle exec foreman start -f Procfile.dev
