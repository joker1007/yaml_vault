module YamlVault
  module Rails
    class << self
      def override_secrets(keys, cryptor_name = nil, **options)
        config = ::Rails.application.config
        ::Rails.application.secrets = begin
          secrets = ActiveSupport::OrderedOptions.new
          yaml = config.paths["config/secrets"].first
          if File.exist?(yaml)
            all_secrets = YamlVault::Main.from_content(IO.read(yaml), keys, cryptor_name, **options).decrypt_hash
            env_secrets = all_secrets[::Rails.env]
            secrets.merge!(env_secrets.symbolize_keys) if env_secrets
          end

          # Fallback to config.secret_key_base if secrets.secret_key_base isn't set
          secrets.secret_key_base ||= config.secret_key_base
          # Fallback to config.secret_token if secrets.secret_token isn't set
          secrets.secret_token ||= config.secret_token

          secrets
        end
      end
    end
  end
end
