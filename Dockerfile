FROM ruby:2.3-alpine

RUN gem install yaml_vault aws-sdk --no-document

ENTRYPOINT ["yaml_vault"]
