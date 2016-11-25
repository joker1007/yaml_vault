FROM ruby:2.3-alpine

RUN gem install yaml_vault --no-document

ENTRYPOINT ["yaml_vault"]
