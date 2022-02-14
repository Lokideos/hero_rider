FROM ruby:2.7.5-alpine

RUN apk add --no-cache \
  build-base \
  tzdata \
  libcurl \
  postgresql-dev

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN gem update bundler && \
  bundle config set without 'development test' && \
  bundle install --jobs 4

COPY . .

EXPOSE 3000

CMD ["bin/puma"]