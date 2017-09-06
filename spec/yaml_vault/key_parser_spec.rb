require 'spec_helper'

describe YamlVault::KeyParser do
  let(:parser) { YamlVault::KeyParser.new }

  describe "#parse" do
    subject(:parse) { parser.parse(str) }

    context %q{str = $.foo.bar.*.[0].:sym.'hoge.fuga'."quoted.path"./regexp/} do
      let(:str) { %q{$.foo.bar.*.[0].:sym.'hoge.fuga'."quoted.path"./regexp/} }

      it { is_expected.to eq(["$", "foo", "bar", "*", 0, ":sym", "hoge.fuga", "quoted.path", /regexp/]) }
    end

    context %q{str = $.'[0]'.':hoge."fuga"'."'path"./\Areg\.exp/} do
      let(:str) { %q{$.'[0]'.':hoge."fuga"'."'path"./\Areg\.exp/} }

      it { is_expected.to eq(["$", "[0]", ":hoge.\"fuga\"", "'path", /\Areg\.exp/]) }
    end

    context %q{str = foo.bar} do
      let(:str) { %q{foo.bar} }

      it { expect { subject }.to raise_error(YamlVault::KeyParser::InvalidPathFormat) }
    end
  end
end
