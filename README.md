# YamlVault
[![Gem Version](https://badge.fury.io/rb/yaml_vault.svg)](https://badge.fury.io/rb/yaml_vault)

Yaml file encryption/decryption helper.

## Encryption Algorithm

yaml_vault uses ActiveSupport::MessageEncryptor.

Default cipher is `aes-256-cbc`.
Default sign digest is `SHA256`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yaml_vault'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yaml_vault

## Usage

### Encrypt

```yml
# secrets.yml
foo: bar

vault:
  secret_data: "hogehoge"
  secrets:
    - 1
    - 2
    - "three"
    - true
    - four: 4
```

yaml_vault encrypts values under `vault` key.

```
% yaml_vault encrypt secrets.yml -o encrypted_secrets.yml
Enter passphrase: <enter your passphrase>
```

output is ...

```yml
# encrypted_secrets.yml
---
foo: bar
vault:
  secret_data: SzZoOGlpcSs4UlBaQnhTYWx0YlN3NHk2QXhiZGYvVmpsc0c3ckllSlh1TT0tLU13ZERzRWsxaGc0Y090blNIdXVVMmc9PQ==--24b2af56d2563776ca316dbfa243333dd053fea1
  secrets:
  - d3hHQVBMZXNsZVJxekdyQ3BjaVBmQT09LS1NQ0Nhckh2MmNraTB0M0U2czhoS1hBPT0=--9b0260204b381a85ba937ee2c056d841c8b85bae
  - dnQzVHJxZ1FXNmFuOE5rQ3p5WFZtdz09LS12ZzlsMWhVNU5aMGdEVCtsK1Y5OWN3PT0=--d9dccae2b49e88331b32ffed072513aee7ffbc22
  - VW5DSnA0a3hCSFJlVktVQUZFQkloQT09LS1qQndVOEt2WCtiRm9zeUN3Qm95NUJnPT0=--b4459fe0f110d8a4d64a704c5bebe4e8dc3b566f
  - OENucHV3K2ZjSzlHTmdESEFJSHhVdz09LS15OUlRaCtlVHVmTDVFMFl2a2pXZkZBPT0=--00f630b1732e73678ebe918a386dd4152c5e9e99
  - four: SXBLZjc0Y2YzRnNBR0FaVzU5SkF0QT09LS1YN3FseWZYcTJ4cEVzSUJmSExOdnNBPT0=--c8dda633ddaba2853161655ab807926f23ea8e59
```

If use `--key` option.

```
% yaml_vault encrypt secrets.yml -o encrypted_secrets.yml -k vault.secret_data
Enter passphrase: <enter your passphrase>
```

output is ...

```yml
# encrypted_secrets.yml
---
foo: bar
vault:
  secret_data: SzZoOGlpcSs4UlBaQnhTYWx0YlN3NHk2QXhiZGYvVmpsc0c3ckllSlh1TT0tLU13ZERzRWsxaGc0Y090blNIdXVVMmc9PQ==--24b2af56d2563776ca316dbfa243333dd053fea1
  secrets:
  - 1
  - 2
  - "three"
  - true
  - four: 4
```

#### AWS KMS Encryption

Max encryptable size is 4096 bytes. (value size as encoded by Base64)

```
% yaml_vault encrypt secrets.yml -o encrypted_secrets.yml --cryptor=aws-kms \
  --aws-region=ap-northeast-1 \
  --aws-kms-key-id=<kms-cms-key-id> \
  --aws-access-key-id=<AWS_ACCESS_KEY_ID> \
  --aws-secret-access-key=<AWS_SECRET_ACCESS_KEY>
```

If region, access_key_id, secret_access_key is not set, use `ENV["AWS_REGION"]`, `ENV["AWS_ACCESS_KEY_ID"]`, `ENV["AWS_SECRET_ACCESS_KEY"]`.

### Decrypt

```
% yaml_vault decrypt encrypted_secrets.yml -o secrets.yml
Enter passphrase: <enter your passphrase>
```

If `ENV["YAML_VAULT_PASSPHRASE"]`, use it as passphrase

#### AWS KMS Decryption

```
% yaml_vault decrypt encrypted_secrets.yml -o secrets.yml --cryptor=aws-kms \
  --aws-region=ap-northeast-1 \
  --aws-access-key-id=<AWS_ACCESS_KEY_ID> \
  --aws-secret-access-key=<AWS_SECRET_ACCESS_KEY>
```

## How to use with docker

```bash
docker run -it \
  -v `pwd`/:/vol \
  joker1007/yaml_vault \
  encrypt /vol/secrets.yml -o /vol/encrypted_secrets.yml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec yaml_vault` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joker1007/yaml_vault.

