#!/usr/bin/env bash
bundle exec rake konacha:serve & bundle exec guard & bundle exec foreman start
