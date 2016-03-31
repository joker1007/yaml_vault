require 'spec_helper'

describe YamlVault do
  describe ".encrypt_yaml" do
    context "use sign_passphrase" do
      it 'generate encrypt yaml' do
        encrypted = YAML.load(YamlVault.encrypt_yaml("testpassphrase", "signpassphrase", File.expand_path("../sample.yml", __FILE__), [["vault"]]))
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
        encrypted = YAML.load(YamlVault.encrypt_yaml("testpassphrase", nil, File.expand_path("../sample.yml", __FILE__), [["vault"]]))
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

  describe ".decrypt_yaml" do
    it 'generate decrypt yaml' do
      decrypted = YAML.load(YamlVault.decrypt_yaml("testpassphrase", "signpassphrase", File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]]))
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
          YamlVault.decrypt_yaml("testpassphrase", "signpassphrase", File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], salt: "dummy")
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end

    context "different sign_passphrase" do
      it do
        expect {
          YamlVault.decrypt_yaml("testpassphrase", "invalidsignpassphrase", File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], salt: "dummy")
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end

    context "different passphrase" do
      it do
        expect {
          YamlVault.decrypt_yaml("invalidpassphrase", "signpassphrase", File.expand_path("../encrypted_sample.yml", __FILE__), [["vault"]], salt: "dummy")
        }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end
  end
end
