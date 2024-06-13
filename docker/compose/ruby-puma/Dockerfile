FROM ruby:3.0.0-alpine

ENV RAILS_ENV development

RUN apk add --update curl git bash build-base \
    postgresql-dev postgresql-client \
    libxml2-dev libcurl curl-dev \
    nodejs npm tzdata
RUN adduser -D -u 1000 amplify

RUN bundle config --global frozen 1
RUN gem install bundler -v 2.4.8
WORKDIR /data

COPY ./Gemfile /data/Gemfile
COPY ./Gemfile.lock /data/Gemfile.lock
COPY ./package.json /data/package.json
COPY ./package-lock.json /data/package-lock.json
RUN bundle install
# RUN npm install --loglevel verbose

COPY . .

# CMD
USER amplify
# ENTRYPOINT ["bundle", "exec", "pumactl", "-F", "config/puma.rb", "start"]
ENTRYPOINT ["bundle", "exec", "rails", "s"]
