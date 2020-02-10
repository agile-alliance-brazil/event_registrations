FROM ruby:2.6.4

WORKDIR /app

RUN apt-get update \
    && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && gem update --system \
    && gem install bundler -v '1.16.1' 

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

RUN bundle install -j 16