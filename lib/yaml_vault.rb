require 'yaml_vault/version'
require 'yaml'
require 'base64'
require 'erb'
require 'active_support'

module YamlVault
  class Main
    class << self
      def from_file(filename, keys, cryptor_name = nil, **options)
        yaml_content = ERB.new(File.read(filename)).result
        new(yaml_content, keys, cryptor_name, **options)
      end

      alias :from_content :new
    end

    def initialize(
      yaml_content, keys, cryptor_name = nil,
      passphrase: nil, sign_passphrase: nil, salt: nil, cipher: "aes-256-cbc", key_len: 32, signature_key_len: 64, digest: "SHA256",
      aws_kms_key_id: nil, aws_region: nil, aws_access_key_id: nil, aws_secret_access_key: nil
    )
      @data = YAML.load(yaml_content)
      @keys = keys

      @passphrase = passphrase
      @sign_passphrase = sign_passphrase
      @salt = salt.to_s
      @cipher = cipher
      @key_len = key_len
      @signature_key_len = signature_key_len
      @digest = digest

      @aws_kms_key_id = aws_kms_key_id
      @aws_region = aws_region
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key

      @cryptor = get_cryptor(cryptor_name)
    end

    def encrypt
      process_yaml do |data|
        do_process(data, :encrypt)
      end
    end

    def decrypt
      process_yaml do |data|
        do_process(data, :decrypt)
      end
    end

    def encrypt_yaml
      encrypt.to_yaml
    end

    def decrypt_yaml
      decrypt.to_yaml
    end

    private

    def get_cryptor(name)
      case name
      when "simple"
        ValueCryptor::Simple.new(@passphrase, @sign_passphrase, @salt, @cipher, @digest, @key_len, @signature_key_len)
      when "aws-kms", "kms"
        ValueCryptor::KMS.new(@aws_kms_key_id, region: @aws_region, aws_access_key_id: @aws_access_key_id, aws_secret_access_key: @aws_secret_access_key)
      else
        ValueCryptor::Simple.new(@passphrase, @sign_passphrase, @salt, @cipher, @digest, @key_len, @signature_key_len)
      end
    end

    def process_yaml
      @keys.each do |key|
        target = key.inject(@data) do |t, part|
          t[part]
        end

        vault_data = yield target

        target_parent = key[0..-2].inject(@data) do |t, part|
          t[part]
        end
        target_parent[key[-1]] = vault_data
      end
      @data
    end

    def do_process(data, method)
      case data
      when Hash
        data.each do |k, v|
          if v.is_a?(Hash) || v.is_a?(Array)
            do_process(v, method)
          else
            data[k] = @cryptor.send(method, v)
          end
        end
      when Array
        data.each_with_index do |v, i|
          if v.is_a?(Hash) || v.is_a?(Array)
            do_process(v, method)
          else
            data[i] = @cryptor.send(method, v)
          end
        end
      else
        @cryptor.send(method, data)
      end
    end

    module ValueCryptor
      class Simple
        def initialize(passphrase, sign_passphrase, salt, cipher, digest, key_size = 32, signature_key_size = 64)
          key = ActiveSupport::KeyGenerator.new(passphrase).generate_key(salt, key_size)
          signature_key = ActiveSupport::KeyGenerator.new(sign_passphrase).generate_key(salt, signature_key_size) if sign_passphrase

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

      class KMS
        def initialize(key_id, region: nil, aws_access_key_id: nil, aws_secret_access_key: nil)
          require 'aws-sdk'
          options = {}
          options[:region] = region if region
          options[:access_key_id] = aws_access_key_id if aws_access_key_id
          options[:secret_access_key] = aws_secret_access_key if aws_secret_access_key
          @client = Aws::KMS::Client.new(options)
          @key_id = key_id
        end

        def encrypt(value)
          resp = @client.encrypt(key_id: @key_id, plaintext: YAML.dump(value))
          Base64.strict_encode64(resp.ciphertext_blob)
        end

        def decrypt(value)
          resp = @client.decrypt(ciphertext_blob: Base64.strict_decode64(value))
          YAML.load(resp.plaintext)
        end
      end
    end

    private_constant :ValueCryptor
  end
end
