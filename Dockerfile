FROM ruby:2.1

# JS Runtime and pg dependencies
RUN apt-get update && apt-get install -y nodejs libpq-dev

# Clean!
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /app/tmp/pids/*

# Ruby base template
COPY Gemfile* /app/
WORKDIR /app

RUN bundle install

CMD ["rails", "s"]