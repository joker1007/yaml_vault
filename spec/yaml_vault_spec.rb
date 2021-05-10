require 'spec_helper'

describe YamlVault, aggregate_failures: true do
  describe ".encrypt_yaml" do
    context "use sign_passphrase" do
      it 'generate encrypt yaml' do
        yaml_file = File.expand_path("../sample.yml", __FILE__)
        origin = YAML.load_file(yaml_file)
        encrypted = YAML.load(YamlVault::Main.from_file(yaml_file, [["$", "vault"], ["$", "default", /\Aa/]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase").encrypt_yaml)
        aggregate_failures do
          expect(origin["vault"]["secret_data"]).to eq "hogehoge"
          expect(origin["vault"]["secrets"][0]).to eq 0
          expect(origin["vault"]["secrets"][1]).to eq 1
          expect(origin["vault"]["secrets"][2]).to eq "two"
          expect(origin["vault"]["secrets"][3]).to eq true
          expect(origin["vault"]["secrets"][4]).to eq({ "four" => 4 })
          expect(origin["vault"]["secrets"][5]).to eq(:five)
          expect(origin["vault"]["secrets"][6]).to eq("bar")
          expect(origin["vault"]["secrets"][7][:a]["b"]).to eq(1..10)
          expect(origin["vault"]["secrets"][8][0]["key1"]).to eq("val1")
          expect(origin["foo"]).to eq "bar"
          expect(origin["default"]["aaa"]).to eq true

          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 0
          expect(encrypted["vault"]["secrets"][1]).not_to eq 1
          expect(encrypted["vault"]["secrets"][2]).not_to eq "two"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({ "four" => 4 })
          expect(encrypted["vault"]["secrets"][5]).not_to eq(:five)
          expect(encrypted["vault"]["secrets"][6]).to eq("bar")
          expect(encrypted["vault"]["secrets"][7][:a]["b"]).not_to eq(1..10)
          expect(encrypted["vault"]["secrets"][8][0]["key1"]).not_to eq("val1")
          expect(encrypted["foo"]).to eq "bar"
          expect(encrypted["default"]["aaa"]).not_to eq true
        end
      end
    end

    context "use no sign_passphrase" do
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [["$", "vault"]], passphrase: "testpassphrase").encrypt_yaml)
        aggregate_failures do
          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 0
          expect(encrypted["vault"]["secrets"][1]).not_to eq 1
          expect(encrypted["vault"]["secrets"][2]).not_to eq "two"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({ "four" => 4 })
          expect(encrypted["vault"]["secrets"][5]).not_to eq(:five)
          expect(encrypted["vault"]["secrets"][6]).to eq("bar")
          expect(encrypted["vault"]["secrets"][7][:a]["b"]).not_to eq(1..10)
          expect(encrypted["vault"]["secrets"][8][0]["key1"]).not_to eq("val1")
          expect(encrypted["foo"]).to eq "bar"
        end
      end
    end

    context "include symbolized matching key" do
      let(:key) { ["$", :symbolized_vault_key] }
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [key], passphrase: "testpassphrase").encrypt_yaml)
        expect(encrypted[:symbolized_vault_key]["secret_data"]).not_to eq "hogehoge"
      end
    end

    context "use prefix and suffix" do
      it 'generate encrypt yaml' do
        yaml_file = File.expand_path("../sample.yml", __FILE__)
        origin = YAML.load_file(yaml_file)
        encrypted = YAML.load(YamlVault::Main.from_file(yaml_file, [["$", "vault"], ["$", "default", /\Aa/]], nil, "{ENC:", "}", passphrase: "testpassphrase", sign_passphrase: "signpassphrase").encrypt_yaml)
        aggregate_failures do
          expect(origin["vault"]["secret_data"]).to eq "hogehoge"
          expect(origin["vault"]["secrets"][0]).to eq 0
          expect(origin["vault"]["secrets"][1]).to eq 1
          expect(origin["vault"]["secrets"][2]).to eq "two"
          expect(origin["vault"]["secrets"][3]).to eq true
          expect(origin["vault"]["secrets"][4]).to eq({ "four" => 4 })
          expect(origin["vault"]["secrets"][5]).to eq(:five)
          expect(origin["vault"]["secrets"][6]).to eq("bar")
          expect(origin["vault"]["secrets"][7][:a]["b"]).to eq(1..10)
          expect(origin["vault"]["secrets"][8][0]["key1"]).to eq("val1")
          expect(origin["foo"]).to eq "bar"
          expect(origin["default"]["aaa"]).to eq true

          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secret_data"]).to start_with "{ENC:"
          expect(encrypted["vault"]["secret_data"]).to end_with "}"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 0
          expect(encrypted["vault"]["secrets"][1]).not_to eq 1
          expect(encrypted["vault"]["secrets"][2]).not_to eq "two"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({ "four" => 4 })
          expect(encrypted["vault"]["secrets"][5]).not_to eq(:five)
          expect(encrypted["vault"]["secrets"][6]).to eq("bar")
          expect(encrypted["vault"]["secrets"][7][:a]["b"]).not_to eq(1..10)
          expect(encrypted["vault"]["secrets"][8][0]["key1"]).not_to eq("val1")
          expect(encrypted["foo"]).to eq "bar"
          expect(encrypted["default"]["aaa"]).not_to eq true
        end
      end
    end
  end

  describe ".decrypt_hash" do
    it 'get decrypted Hash object' do
      decrypted = YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["$", "vault"]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase").decrypt_hash
      aggregate_failures do
        expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
        expect(decrypted["vault"]["secrets"][0]).to eq 0
        expect(decrypted["vault"]["secrets"][1]).to eq 1
        expect(decrypted["vault"]["secrets"][2]).to eq "two"
        expect(decrypted["vault"]["secrets"][3]).to eq true
        expect(decrypted["vault"]["secrets"][4]).to eq({ "four" => 4 })
        expect(decrypted["vault"]["secrets"][5]).to eq(:five)
        expect(decrypted["vault"]["secrets"][6][:a]["b"]).to eq(1..10)
        expect(decrypted["vault"]["secrets"][7][0]["key1"]).to eq("val1")
        expect(decrypted["foo"]).to eq "bar"
      end
    end
  end

  describe ".decrypt_yaml" do
    it 'generate decrypt yaml' do
      decrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["$", "vault"]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase").decrypt_yaml)
      aggregate_failures do
        expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
        expect(decrypted["vault"]["secrets"][0]).to eq 0
        expect(decrypted["vault"]["secrets"][1]).to eq 1
        expect(decrypted["vault"]["secrets"][2]).to eq "two"
        expect(decrypted["vault"]["secrets"][3]).to eq true
        expect(decrypted["vault"]["secrets"][4]).to eq({ "four" => 4 })
        expect(decrypted["vault"]["secrets"][5]).to eq(:five)
        expect(decrypted["vault"]["secrets"][6][:a]["b"]).to eq(1..10)
        expect(decrypted["vault"]["secrets"][7][0]["key1"]).to eq("val1")
        expect(decrypted["foo"]).to eq "bar"
      end
    end

    context "different salt" do
      it do
        expect {
          YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["$", "vault"]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase", salt: "dummy").decrypt_yaml
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end

    context "different sign_passphrase" do
      it do
        expect {
          YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["$", "vault"]], passphrase: "testpassphrase", sign_passphrase: "invalidsignpassphrase", salt: "dummy").decrypt_yaml
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end

    context "different passphrase" do
      it do
        expect {
          YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["$", "vault"]], passphrase: "invalidpassphrase", sign_passphrase: "signpassphrase", salt: "dummy").decrypt_yaml
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end
  end

  if ENV["AWS_KMS_KEY_ID"]
    describe ".encrypt_yaml" do
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [["$", "vault"]], "aws-kms", aws_kms_key_id: ENV["AWS_KMS_KEY_ID"]).encrypt_yaml)
        aggregate_failures do
          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 0
          expect(encrypted["vault"]["secrets"][1]).not_to eq 1
          expect(encrypted["vault"]["secrets"][2]).not_to eq "two"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({ "four" => 4 })
          expect(encrypted["vault"]["secrets"][5]).not_to eq(:five)
          expect(encrypted["vault"]["secrets"][6][:a]["b"]).not_to eq(1..10)
          expect(encrypted["vault"]["secrets"][7][0]["key1"]).not_to eq("val1")
          expect(encrypted["foo"]).to eq "bar"
        end

        decrypted = YAML.load(YamlVault::Main.new(YAML.dump(encrypted), [["$", "vault"]], "aws-kms").decrypt_yaml)
        aggregate_failures do
          expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
          expect(decrypted["vault"]["secrets"][0]).to eq 0
          expect(decrypted["vault"]["secrets"][1]).to eq 1
          expect(decrypted["vault"]["secrets"][2]).to eq "two"
          expect(decrypted["vault"]["secrets"][3]).to eq true
          expect(decrypted["vault"]["secrets"][4]).to eq({ "four" => 4 })
          expect(decrypted["vault"]["secrets"][5]).to eq(:five)
          expect(decrypted["vault"]["secrets"][6][:a]["b"]).to eq(1..10)
          expect(decrypted["vault"]["secrets"][7][0]["key1"]).to eq("val1")
          expect(decrypted["foo"]).to eq "bar"
        end
      end
    end
  end

  describe ".encrypt_yaml" do
    if ENV["GCP_KMS_RESOURCE_ID"] && ENV["GCP_CREDENTIAL_FILE"]
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [["$", "vault"]], "gcp-kms", gcp_kms_resource_id: ENV["GCP_KMS_RESOURCE_ID"], gcp_credential_file: ENV["GCP_CREDENTIAL_FILE"]).encrypt_yaml)
        aggregate_failures do
          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 0
          expect(encrypted["vault"]["secrets"][1]).not_to eq 1
          expect(encrypted["vault"]["secrets"][2]).not_to eq "two"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({ "four" => 4 })
          expect(encrypted["vault"]["secrets"][5]).not_to eq(:five)
          expect(encrypted["vault"]["secrets"][6][:a]["b"]).not_to eq(1..10)
          expect(encrypted["vault"]["secrets"][7][0]["key1"]).not_to eq("val1")
          expect(encrypted["foo"]).to eq "bar"
        end

        decrypted = YAML.load(YamlVault::Main.new(YAML.dump(encrypted), [["$", "vault"]], "gcp-kms", gcp_kms_resource_id: ENV["GCP_KMS_RESOURCE_ID"], gcp_credential_file: ENV["GCP_CREDENTIAL_FILE"]).decrypt_yaml)
        aggregate_failures do
          expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
          expect(decrypted["vault"]["secrets"][0]).to eq 0
          expect(decrypted["vault"]["secrets"][1]).to eq 1
          expect(decrypted["vault"]["secrets"][2]).to eq "two"
          expect(decrypted["vault"]["secrets"][3]).to eq true
          expect(decrypted["vault"]["secrets"][4]).to eq({ "four" => 4 })
          expect(decrypted["vault"]["secrets"][5]).to eq(:five)
          expect(decrypted["vault"]["secrets"][6][:a]["b"]).to eq(1..10)
          expect(decrypted["vault"]["secrets"][7][0]["key1"]).to eq("val1")
          expect(decrypted["foo"]).to eq "bar"
        end
      end
    end

    if ENV["GCP_KMS_RESOURCE_ID"]
      it 'generate encrypt yaml by GOOGLE_APPLICATION_CREDENTIAL' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [["$", "vault"]], "gcp-kms", gcp_kms_resource_id: ENV["GCP_KMS_RESOURCE_ID"]).encrypt_yaml)
        aggregate_failures do
          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 0
          expect(encrypted["vault"]["secrets"][1]).not_to eq 1
          expect(encrypted["vault"]["secrets"][2]).not_to eq "two"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({ "four" => 4 })
          expect(encrypted["vault"]["secrets"][5]).not_to eq(:five)
          expect(encrypted["vault"]["secrets"][6][:a]["b"]).not_to eq(1..10)
          expect(encrypted["vault"]["secrets"][7][0]["key1"]).not_to eq("val1")
          expect(encrypted["foo"]).to eq "bar"
        end

        decrypted = YAML.load(YamlVault::Main.new(YAML.dump(encrypted), [["$", "vault"]], "gcp-kms", gcp_kms_resource_id: ENV["GCP_KMS_RESOURCE_ID"]).decrypt_yaml)
        aggregate_failures do
          expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
          expect(decrypted["vault"]["secrets"][0]).to eq 0
          expect(decrypted["vault"]["secrets"][1]).to eq 1
          expect(decrypted["vault"]["secrets"][2]).to eq "two"
          expect(decrypted["vault"]["secrets"][3]).to eq true
          expect(decrypted["vault"]["secrets"][4]).to eq({ "four" => 4 })
          expect(decrypted["vault"]["secrets"][5]).to eq(:five)
          expect(decrypted["vault"]["secrets"][6][:a]["b"]).to eq(1..10)
          expect(decrypted["vault"]["secrets"][7][0]["key1"]).to eq("val1")
          expect(decrypted["foo"]).to eq "bar"
        end
      end
    end
  end
end
