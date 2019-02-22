FROM ruby:2.4.3

WORKDIR /app
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN apt-get update \
    && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && gem update --system \
    && gem install bundler -v '1.16.1' \
    && bundle install -j 16