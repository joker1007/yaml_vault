require 'yaml_vault/version'
require 'yaml'
require 'base64'
require 'erb'
require 'active_support'
require 'pp'

require 'yaml_vault/key_parser'
require 'yaml_vault/yaml_tree_builder'

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
      aws_kms_key_id: nil, aws_region: nil, aws_access_key_id: nil, aws_secret_access_key: nil, aws_profile: nil,
      gcp_kms_resource_id: nil, gcp_credential_file: nil
    )
      @yaml = yaml_content
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
      @aws_profile = aws_profile

      @gcp_kms_resource_id = gcp_kms_resource_id
      @gcp_credential_file = gcp_credential_file

      @cryptor = get_cryptor(cryptor_name)
    end

    def encrypt
      parser = YAML::Parser.new(YamlVault::YAMLTreeBuilder.new(@keys, @cryptor, :encrypt))
      parser.parse(@yaml).handler.root
    end

    def decrypt
      parser = YAML::Parser.new(YamlVault::YAMLTreeBuilder.new(@keys, @cryptor, :decrypt))
      parser.parse(@yaml).handler.root
    end

    def encrypt_hash
      encrypt.to_ruby[0]
    end

    def decrypt_hash
      decrypt.to_ruby[0]
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
        ValueCryptor::KMS.new(@aws_kms_key_id, region: @aws_region, aws_access_key_id: @aws_access_key_id, aws_secret_access_key: @aws_secret_access_key, aws_profile: @aws_profile)
      when "gcp-kms"
        ValueCryptor::GCPKMS.new(@gcp_kms_resource_id, @gcp_credential_file)
      else
        ValueCryptor::Simple.new(@passphrase, @sign_passphrase, @salt, @cipher, @digest, @key_len, @signature_key_len)
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
        def initialize(key_id, region: nil, aws_access_key_id: nil, aws_secret_access_key: nil, aws_profile: nil)
          begin
            begin
              require 'aws-sdk-kms'
            rescue LoadError
              begin
                require 'aws-sdk'
              rescue LoadError
                puts "Please install aws-sdk v2 or aws-sdk-kms (aws-sdk v3)"
                exit 1
              end
            end
          end
          options = {}
          options[:region] = region if region
          options[:access_key_id] = aws_access_key_id if aws_access_key_id
          options[:secret_access_key] = aws_secret_access_key if aws_secret_access_key
          options[:profile] = aws_profile if aws_profile
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

      class GCPKMS
        def initialize(resource_id, credential_file)
          raise "Need key resource id" unless resource_id
          begin
            require 'googleauth'
            require 'google/apis/cloudkms_v1'
          rescue LoadError
            puts "Please install google-api-client (>= 0.11.0)"
            exit 1
          end

          scope = [
            'https://www.googleapis.com/auth/cloud-platform'
          ]

          @resource_id = resource_id
          @client = Google::Apis::CloudkmsV1::CloudKMSService.new
          if credential_file
            @client.authorization = Google::Auth::DefaultCredentials.make_creds(
              json_key_io: File.open(credential_file),
              scope: scope
            )
          else
            @client.authorization = Google::Auth.get_application_default(scope)
          end
        end

        def encrypt(value)
          response = @client.encrypt_crypto_key(@resource_id, {plaintext: YAML.dump(value)}, {})
          Base64.strict_encode64(response.ciphertext)
        end

        def decrypt(value)
          response = @client.decrypt_crypto_key(@resource_id, {ciphertext: Base64.strict_decode64(value)}, {})
          YAML.load(response.plaintext)
        end
      end
    end

    private_constant :ValueCryptor
  end
end
