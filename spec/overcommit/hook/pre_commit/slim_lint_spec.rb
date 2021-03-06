require 'spec_helper'

describe Overcommit::Hook::PreCommit::SlimLint do
  let(:config)  { Overcommit::ConfigurationLoader.default_configuration }
  let(:context) { double('context') }
  subject { described_class.new(config, context) }

  before do
    subject.stub(:applicable_files).and_return(%w[file1.slim file2.slim])
  end

  context 'when slim-lint exits successfully' do
    before do
      result = double('result')
      result.stub(:success?).and_return(true)
      subject.stub(:execute).and_return(result)
    end

    it { should pass }
  end

  context 'when slim-lint exits unsucessfully' do
    let(:result) { double('result') }

    before do
      result.stub(:success?).and_return(false)
      subject.stub(:execute).and_return(result)
    end

    context 'and it reports a warning' do
      before do
        result.stub(:stdout).and_return([
          'file1.slim:1 [W] Prefer single quoted strings',
        ].join("\n"))
      end

      it { should warn }
    end

    context 'and it reports an error' do
      before do
        result.stub(:stdout).and_return([
          'file1.slim:1 [E] Unbalanced brackets',
        ].join("\n"))
      end

      it { should fail_hook }
    end
  end
end
