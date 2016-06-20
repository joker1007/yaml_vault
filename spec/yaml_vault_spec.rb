require 'spec_helper'

describe YamlVault do
  describe ".encrypt_yaml" do
    context "use sign_passphrase" do
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [["vault"]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase").encrypt_yaml)
        aggregate_failures do
          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 1
          expect(encrypted["vault"]["secrets"][1]).not_to eq 2
          expect(encrypted["vault"]["secrets"][2]).not_to eq "three"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({"four" => 4})
          expect(encrypted["foo"]).to eq "bar"
        end
      end
    end

    context "use no sign_passphrase" do
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [["vault"]], passphrase: "testpassphrase").encrypt_yaml)
        aggregate_failures do
          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 1
          expect(encrypted["vault"]["secrets"][1]).not_to eq 2
          expect(encrypted["vault"]["secrets"][2]).not_to eq "three"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({"four" => 4})
          expect(encrypted["foo"]).to eq "bar"
        end
      end
    end
  end

  describe ".decrypt" do
    it 'get decrypted Hash object' do
      decrypted = YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase").decrypt
      aggregate_failures do
        expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
        expect(decrypted["vault"]["secrets"][0]).to eq 1
        expect(decrypted["vault"]["secrets"][1]).to eq 2
        expect(decrypted["vault"]["secrets"][2]).to eq "three"
        expect(decrypted["vault"]["secrets"][3]).to eq true
        expect(decrypted["vault"]["secrets"][4]).to eq({"four" => 4})
        expect(decrypted["foo"]).to eq "bar"
      end
    end
  end

  describe ".decrypt_yaml" do
    it 'generate decrypt yaml' do
      decrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase").decrypt_yaml)
      aggregate_failures do
        expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
        expect(decrypted["vault"]["secrets"][0]).to eq 1
        expect(decrypted["vault"]["secrets"][1]).to eq 2
        expect(decrypted["vault"]["secrets"][2]).to eq "three"
        expect(decrypted["vault"]["secrets"][3]).to eq true
        expect(decrypted["vault"]["secrets"][4]).to eq({"four" => 4})
        expect(decrypted["foo"]).to eq "bar"
      end
    end

    context "different salt" do
      it do
        expect {
          YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], passphrase: "testpassphrase", sign_passphrase: "signpassphrase", salt: "dummy").decrypt_yaml
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end

    context "different sign_passphrase" do
      it do
        expect {
          YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], passphrase: "testpassphrase", sign_passphrase: "invalidsignpassphrase", salt: "dummy").decrypt_yaml
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end

    context "different passphrase" do
      it do
        expect {
          YamlVault::Main.from_file(File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], passphrase: "invalidpassphrase", sign_passphrase: "signpassphrase", salt: "dummy").decrypt_yaml
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end
  end

  if ENV["AWS_KMS_KEY_ID"]
    describe ".encrypt_yaml" do
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../sample.yml", __FILE__), [["vault"]], "aws-kms", aws_kms_key_id: ENV["AWS_KMS_KEY_ID"]).encrypt_yaml)
        aggregate_failures do
          expect(encrypted["vault"]["secret_data"]).not_to eq "hogehoge"
          expect(encrypted["vault"]["secrets"][0]).not_to eq 1
          expect(encrypted["vault"]["secrets"][1]).not_to eq 2
          expect(encrypted["vault"]["secrets"][2]).not_to eq "three"
          expect(encrypted["vault"]["secrets"][3]).not_to eq true
          expect(encrypted["vault"]["secrets"][4]).not_to eq({"four" => 4})
          expect(encrypted["foo"]).to eq "bar"
        end
      end
    end

    describe ".decrypt_yaml" do
      it 'generate decrypt yaml' do
        decrypted = YAML.load(YamlVault::Main.from_file(File.expand_path("../kms_encrypted_sample.yml", __FILE__), [["vault"]], "aws-kms").decrypt_yaml)
        aggregate_failures do
          expect(decrypted["vault"]["secret_data"]).to eq "hogehoge"
          expect(decrypted["vault"]["secrets"][0]).to eq 1
          expect(decrypted["vault"]["secrets"][1]).to eq 2
          expect(decrypted["vault"]["secrets"][2]).to eq "three"
          expect(decrypted["vault"]["secrets"][3]).to eq true
          expect(decrypted["vault"]["secrets"][4]).to eq({"four" => 4})
          expect(decrypted["foo"]).to eq "bar"
        end
      end
    end
  end
end
