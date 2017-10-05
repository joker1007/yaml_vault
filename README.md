# YamlVault
[![Gem Version](https://badge.fury.io/rb/yaml_vault.svg)](https://badge.fury.io/rb/yaml_vault)
[![Build Status](https://travis-ci.org/joker1007/yaml_vault.svg?branch=master)](https://travis-ci.org/joker1007/yaml_vault)

Yaml file encryption/decryption helper.

## Breaking Change from 0.x to 1.0
- Output YAML file keeps alias & anchor syntax & tag info. (But empty line is trimmed)
- `--key` format is changed. (Need `$` as root document at first)
- `--key` supports new formats. (Root Doc, Wildcard, Regexp, Quote)

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

default: &default
  hoge: fuga
  aaa: true
  bbb: 2

foo: bar

complicated:
  - 1
  - ["hoge", "fuga"]
  - [{key1: val1, key2: val2}, {key3: val3}]
  - a:
      b:
        c: d
        e: !ruby/range 1..10

test:
  <<: *default
  hoge:
    - 1
    - 2
    - 3

vault:
  secret_data: "hogehoge"
  secrets:
    - 0
    - 1
    - "two"
    - true
    - four: 4
    - :five
    - :a:
        b: !ruby/range 1..10
    - [{key1: val1, key2: val2}, {key3: val3}]
```

```
% yaml_vault encrypt secrets.yml -o encrypted_secrets.yml"
Enter passphrase: <enter your passphrase>
```

output is ...

```yml
# encrypted_secrets.yml

default: &default
  hoge: cTlEZkloUDlBS0F3VGdzL25PcXZRUT09LS1QdEFSZklJRlpGTWNVLzU5RC9IT2VnPT0=--f68324e76662ee92be4ff11faabf963bcba9b464d2a0af8cb505611755cf698c
  aaa: RUNneXhXYnBVVVRod0o1aTN2ZkRRZz09LS1BYjBYQXp3OGI2dE9TMERKNVZGbzd3PT0=--81ca6f9320426bfb52e4318c209ebe9e1e0f7ff54567aed4dd6a0ae9d7dce22b
  bbb: c2ExRXFpUXZKN1ltanRRUHpxMGduQT09LS1jWjVpbG9tTk9BRFdRc0QvbTBSVFBBPT0=--c63c47a104032b6aa4169ec58df5d2c4e0c5f38febbfb8f2167ae034fb93f488
foo: cWs4SmFVN3NXMGNra2tMUS9Ucmx5Zz09LS1meElVMXp0MSs0UGtrbW1tcnFKTnBnPT0=--ce755376767167c71a389637080465884295be1094e203a5c5ef396c2f13b7a8
complicated:
- ejBlc09wejFITmRpOUVBWVduQmZiQT09LS12YzdZN1hselkzQWNIOWpYd3QrR0dRPT0=--1fa11f7719fb0ffc7ce50eda52b8813d8ca547c341e710c044f8282767a22cfb
- ["ZHFlWjN3cUdMdFdFTDQwM2w0WW8xUT09LS1aOTNwU2NtQ0IvWHNYU1dJZGFCMUl3PT0=--b1ac20a6388d46e2e36bb50553cf89af673fbb4ff7ab83e96f0a315e806f5cd0",
  "L0pBVHVMSXdlMEVQbTRKTGJKb2pOZz09LS1xTjRRbEs3SFpDK2szRlpDYTFuYlV3PT0=--d65702ec4880c52dfe074a12af02498e16b84452231ca2390205a752b19b4986"]
- [{key1: dmNxVjI3c242YngwcHY4cGhJTmRZUT09LS1jYXh1LzdyTy9FK1VwVjVidkU1aUNBPT0=--b04624c5b3a7c5dfbdc5a69811cb5a194fbbd6da0d2266231d25d0bee9da3bf6,
    key2: eHBOM0xlRmczRFl1UERRdCtzbGF3dz09LS1TTjdWdHlqVlIreUhtekE0VGpsVEt3PT0=--ccd53fcfc3d3f51f5b4a97f5b1508e77e9149b0100995e0588b289fde920aba7},
  {key3: VHg2V2VHWjZCcHhHRWJZTHFXZGhUZz09LS1kTisvY3FZaDlaTEFjODNXeFQwTjFBPT0=--e6f809a272f4a7b347f4fcf28241cd51b1293310a1e7d372f19488c2c7a726e2}]
- a:
    b:
      c: d254QmFnRFprMUJldDBkRjlVWUpMQT09LS1CTFhQUUQzWUw3K3FUQnJVWkFLRzdnPT0=--85522ae049be7808ae77b586c9e9e1af225b08c44becbe60ec1995f2f4b31668
      e: enBYUkYrMkt1ZkdHd2JHbzAyNFo3czBpVmZRU0psaDNMalcyU2lKbEQvUT0tLVF5QSt6RXd2L0ptbHp0UVZCcm9LdXc9PQ==--06e9fa609a5a8f9f81997b314e54a91959088819b8a0f05fede68769d841ee3b
test:
  <<: *default
  hoge:
  - eERDbWVSeFhZNkJzNVFvSkRVMWFaZz09LS02WVFSamRDbmxEbXF4WExkSTFvUzl3PT0=--05bf3dcd005b32455409c70212d64452b0af3ec78471fa69760ad85dcd6147d4
  - Y1BPRGZIQys0bTBJdFJuV21WSWJBUT09LS1xZFdQcmVpd3ltWnVSWEttcVZ1Z3VRPT0=--6c57387b420bc569494a0308e896d8426ec7b6a649a6a1f890e779bc792fc9a0
  - anVLa2dXTWo1ckVVTlhQZG0vdVRHZz09LS04K3FIV2lsSUI5V01pR1ljS3lCWDVnPT0=--545a128c08152415ff27c35c89cb0ab1b5625530716ac8f8daf5f2e61fbe450c
vault:
  secret_data: "NUR1aFdaMjMrSkI2MyswRC84UXJzWUprVXgvZnBmRXhBM0dqUWdpOTBMaz0tLUJ4NmtpeUQ3dG0rN080cDZMWmlwc1E9PQ==--7e812eabdc22af8e46db8a7b8f361deb6484d3aa8568d4bc95d6e73c00149c28"
  secrets:
  - emExNlNIQ2tiNTliU1ZhU1FzUXBtQT09LS1pajcyYUU0bnlYSlorTEtFOEZyZVRRPT0=--c8483428c33401e99e55e7634ba468bcba219ab02034bb4ad80c89d639f52323
  - NXJ4c2JId0xLWUk0dHY2NHJyVzNIdz09LS0vUnlpWGptaitmYUZ0bk4zY1I0YWVnPT0=--18f9764a068ba555c5261be70de469e0460ef14b8a1636f418bddcb0b7b4ffcf
  - "WUFwWTEzK1lpOHJseGEwbGFmTEs4dz09LS1EK2xwNUFsSExQT2Zwa0p5QjFGbWJnPT0=--3f66ca21b4f1bae17d03233afc0ee80a1a42371244ac38ce71f284266bec3a95"
  - dGd2d1k4MTFSMHp3cy9xZE9NaGpIUT09LS1GcWNKdisxMlRGTzBLV2Zjam9PRmZ3PT0=--1f19086e9908d4c5313c3abfab8f6c8697785273c14ab0a2f39634a57ac57e72
  - four: QXlGUGsyYnB6dEtNWk9ia3MvR2duZz09LS1DWGprWVVIS2VkbjJrYnl0MkVmcUlBPT0=--0e426924db2fa7e577e4e4d7d62ce8f7e9390f14e72f90aca59be88df252b110
  - dDAvZzdNampwUmsrY1Q3ME5VaWNkQT09LS13YUJQVm9kZXpFMlpxVTVPRDJ3RG1RPT0=--c53ab9535f06eef08e41dbf9fd1641421760309f381c37016ce27d17d6910f11
  - :a:
      b: NHgycERIaXlQaTR2V09weWFUbG9DZE1aQ3pTZ1h0OWo0VzJ4NkRMaDk5WT0tLWhMc21MUHJOQnowTHlnSnhxUkluNVE9PQ==--081f7b5f9bc982f7270454a8453b5fcf860bea9ed6f8454a0f8509b0cc2a8638
  - [{key1: WHkwOEc5NVcvNm5IMTVNc24xWUtYdz09LS1GZGc0K2J2V3F5bW5iS29Vb1grcFNRPT0=--c453f9e814e4d62294d1d5d20b71db8825e8f94933ad8af157ca7860407e39c5,
      key2: eUZlQlgzVTFFRjVKUjF3dTZ6RlRidz09LS1rUzRtN2VlS2ZmRDFuR3JCMkRMRTNRPT0=--d30ebbf61e5393d3502e71486379215c4ea95d3f4697faa209214dd23d64e1fd},
    {key3: YStlVTBFZjZQQlVDWHhjMS85L052Zz09LS0rL2JtbUI2eFY2QVZsbG92OGM4Z2lnPT0=--ffc85954e68fdde7e03fdbaa715c43d624c2825e28439de3ce2d2fa0e9debe0b}]
```

If use `--key` option.

```
% yaml_vault encrypt secrets.yml -o encrypted_secrets.yml -k $.vault.secret_data
Enter passphrase: <enter your passphrase>
```

output is ...

```yml
# encrypted_secrets.yml

default: &default
  hoge: fuga
  aaa: true
  bbb: 2
foo: bar
complicated:
  - 1
  - ["hoge", "fuga"]
  - [{key1: val1, key2: val2}, {key3: val3}]
  - a:
      b:
        c: d
        e: !ruby/range 1..10
test:
  <<: *default
  hoge:
    - 1
    - 2
    - 3
vault:
  secret_data: SzZoOGlpcSs4UlBaQnhTYWx0YlN3NHk2QXhiZGYvVmpsc0c3ckllSlh1TT0tLU13ZERzRWsxaGc0Y090blNIdXVVMmc9PQ==--24b2af56d2563776ca316dbfa243333dd053fea1
  secrets:
  - 1
  - 2
  - "three"
  - true
  - four: 4
```

`--key` option supports following format.

- `$` as root document
- `*` as wildcard for array or map key
- `/str/` as regexp to map key
- `:<key_name>` as Symbol.
- `[0]` as array key.
- `'str'` as map key (inner single quote string).
- `"str"` as map key (inner double quote string).
- `other_string` as map key

`--key` must start with `$`.

ex. `$.production.:slaves.[0].*.:password`

#### AWS KMS Encryption

Max encryptable size is 4096 bytes. (value size as encoded by Base64)

```
% yaml_vault encrypt secrets.yml -o encrypted_secrets.yml --cryptor=aws-kms \
  --aws-region=ap-northeast-1 \
  --aws-kms-key-id=<kms-cms-key-id> \
  --aws-access-key-id=<AWS_ACCESS_KEY_ID> \
  --aws-secret-access-key=<AWS_SECRET_ACCESS_KEY>
```

If region, access_key_id, secret_access_key is not set, use `ENV["AWS_REGION"]`, `ENV["AWS_ACCESS_KEY_ID"]`, `ENV["AWS_SECRET_ACCESS_KEY"]` or default credentials or Instance Profile.

#### GCP KMS Encryption

```
% yaml_vault encrypt secrets.yml -o encrypted_secrets.yml --cryptor=gcp-kms \
  --gcp-kms-resource-id=<kms-resource-id> \
  --gcp-credential-file=<credential-json-file-path>
```

ex. `--gcp-kms-resource-id=projects/<PROJECT_ID>/locations/global/keyRings/<KEYRING_ID>/cryptoKeys/<KEY_ID>`

If gcp_credential_file is not set, use Google Application Default Credentials flow (https://developers.google.com/identity/protocols/application-default-credentials)

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

#### GCP KMS Decryption

```
% yaml_vault decrypt encrypted_secrets.yml -o secrets.yml --cryptor=gcp-kms \
  --gcp-kms-resource-id=<kms-resource-id> \
  --gcp-credential-file=<credential-json-file-path>
```

### Direct Assignment

```ruby
# decrypt `configs['vault']` and `configs['production']['password']`

# Simple Encryption
configs = YamlVault::Main.from_file(
  File.expand_path("../encrypted_sample.yml", __FILE__),
  [["vault"], ["production", "password"]],
  passphrase: ENV["YAML_VAULT_PASSPHRASE"], sign_passphrase: ENV["YAML_VAULT_SIGN_PASSPHRASE"]
).decrypt

# AWS KMS
configs = YamlVault::Main.from_file(
  File.expand_path("../encrypted_sample.yml", __FILE__),
  [["vault"], ["production", "password"]],
  "kms",
  aws_kms_key_id: ENV["AWS_KMS_KEY_ID"],
  aws_region: ENV["AWS_REGION"],     # optional
  aws_access_key_id: "xxxxxxx",      # optional
  aws_secret_access_key: "xxxxxxx",  # optional
).decrypt

# GCP KMS
configs = YamlVault::Main.from_file(
  File.expand_path("../encrypted_sample.yml", __FILE__),
  [["vault"], ["production", "password"]],
  "gcp-kms",
  gcp_kms_resource_id: "xxxxxxx",
  gcp_credential_file: File.expand_path("../credential.json", __FILE__)
).decrypt
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

