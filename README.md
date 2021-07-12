<a href="https://codeclimate.com/github/agile-alliance-brazil/event_registrations/maintainability"><img src="https://api.codeclimate.com/v1/badges/58071b0f875df42f60d0/maintainability" /></a>
<a href="https://codeclimate.com/github/agile-alliance-brazil/event_registrations/test_coverage"><img src="https://api.codeclimate.com/v1/badges/58071b0f875df42f60d0/test_coverage" /></a>
![EventRegistrationsBuild](https://github.com/agile-alliance-brazil/event_registrations/workflows/EventRegistrationsBuild/badge.svg)


# Sistema de Inscrições

## Using:
- Sendgrid to send emails
- Rollbar to monitor production errors
- RSpec as test framework
- Fabrication as factory for specs
- Faker to generate fake data

## How to build the environment

- Install rvm or rbenv - the main development team is using *rvm*
- If you choose rvm then
    - Install the correct version (the examples will use the ruby-3.0.1)
        - `rvm install ruby-3.0.1`
    - Create the gemset to the project under the correct version
        - In the project folder run:
            - `rvm use 3.0.1@event_registrations --create`
            - `rvm --ruby-version use 3.0.1`
            - `gem install bundler -v 1.17.3`
            - `bundle install`
- Install PostgreSQL v. 13.3
- Start postgresql
    - Example on macOS (brew instalation): `pg_ctl -D /usr/local/var/postgres start`
- Check `database.yml` for further configuration
- In the project folder run:
    - `rake db:create`
    - `rake db:migrate`
    - `rake db:create RAILS_ENV=test`
    - `rake db:migrate RAILS_ENV=test`

- CI/CD: Github actions
    - Check [Github Actions](https://github.com/agile-alliance-brazil/event_registrations/tree/develop/.github/workflows)

- The build relies on `rspec` and `rubocop` success
- In the project folder you should be able to run and check the output of:
    - `rspec`
    - `rubocop -A`

- Run console: `rails c`
- Run server: `rails s`
