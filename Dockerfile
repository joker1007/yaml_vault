FROM ruby:2.3.1

WORKDIR /usr/src/app
ADD . /usr/src/app

RUN ./bin/setup
RUN bundle exec rake install
