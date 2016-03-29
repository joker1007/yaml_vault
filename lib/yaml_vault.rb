require 'yaml_vault/version'
require 'yaml'
require 'erb'
require 'active_support'

module YamlVault
  class << self
    def encrypt_yaml(passphrase, yaml, keys, salt: nil, cipher: nil)
      process_yaml(passphrase, yaml, keys, salt: salt.to_s, cipher: cipher) do |cryptor, data|
        do_process(cryptor, data, :encrypt)
      end
    end

    def decrypt_yaml(passphrase, yaml, keys, salt: nil, cipher: nil)
      process_yaml(passphrase, yaml, keys, salt: salt.to_s, cipher: cipher) do |cryptor, data|
        do_process(cryptor, data, :decrypt)
      end
    end

    private

    def process_yaml(passphrase, yaml, keys, salt:, cipher:)
      cryptor = ValueCryptor.new(passphrase, salt, cipher)
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
    def initialize(passphrase, salt, cipher)
      key = ActiveSupport::KeyGenerator.new(passphrase, cipher: cipher || 'aes-256-cbc').generate_key(salt)
      @cryptor = ActiveSupport::MessageEncryptor.new(key)
    end

    def encrypt(value)
      @cryptor.encrypt_and_sign(value)
    end

    def decrypt(value)
      @cryptor.decrypt_and_verify(value)
    end
  end
end
