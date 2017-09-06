FROM ruby:2.4-alpine

ARG version

RUN gem install yaml_vault --no-document --version ${version} \
 && gem install aws-sdk-kms google-api-client

ENTRYPOINT ["yaml_vault"]
