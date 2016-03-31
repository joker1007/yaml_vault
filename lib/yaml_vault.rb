require 'yaml_vault/version'
require 'yaml'
require 'erb'
require 'active_support'

module YamlVault
  class << self
    def encrypt_yaml(passphrase, sign_passphrase, yaml, keys, salt: nil, cipher: "aes-256-cbc", digest: "SHA256")
      process_yaml(passphrase, sign_passphrase, yaml, keys, salt: salt.to_s, cipher: cipher, digest: digest) do |cryptor, data|
        do_process(cryptor, data, :encrypt)
      end
    end

    def decrypt_yaml(passphrase, sign_passphrase, yaml, keys, salt: nil, cipher: "aes-256-cbc", digest: "SHA256")
      process_yaml(passphrase, sign_passphrase, yaml, keys, salt: salt.to_s, cipher: cipher, digest: digest) do |cryptor, data|
        do_process(cryptor, data, :decrypt)
      end
    end

    private

    def process_yaml(passphrase, sign_passphrase, yaml, keys, salt:, cipher:, digest:)
      cryptor = ValueCryptor.new(passphrase, sign_passphrase, salt, cipher, digest)
      data = YAML.load(ERB.new(File.read(yaml)).result)
      keys.each do |key|
        target = key.inject(data) do |t, part|
          t[part]
        end

        vault_data = yield cryptor, target

        target_parent = key[0..-2].inject(data) do |t, part|
          t[part]
        end
        target_parent[key[-1]] = vault_data
      end
      data.to_yaml
    end

    def do_process(cryptor, data, method)
      case data
      when Hash
        data.each do |k, v|
          if v.is_a?(Hash) || v.is_a?(Array)
            do_process(cryptor, v, method)
          else
            data[k] = cryptor.send(method, v)
          end
        end
      when Array
        data.each_with_index do |v, i|
          if v.is_a?(Hash) || v.is_a?(Array)
            do_process(cryptor, v, method)
          else
            data[i] = cryptor.send(method, v)
          end
        end
      else
        cryptor.send(method, data)
      end
    end
  end

  class ValueCryptor
    def initialize(passphrase, sign_passphrase, salt, cipher, digest, key_size = 64)
      key = ActiveSupport::KeyGenerator.new(passphrase).generate_key(salt, key_size)
      signature_key = ActiveSupport::KeyGenerator.new(sign_passphrase).generate_key(salt, key_size) if sign_passphrase

      if signature_key
        @cryptor = ActiveSupport::MessageEncryptor.new(key, signature_key, cipher: cipher, digest: digest)
      else
        @cryptor = ActiveSupport::MessageEncryptor.new(key, cipher: cipher, digest: digest)
      end
    end

    def encrypt(value)
      @cryptor.encrypt_and_sign(value)
    end

    def decrypt(value)
      @cryptor.decrypt_and_verify(value)
    end
  end

  private_constant :ValueCryptor
end
