require 'spec_helper'
require 'gonzo/providers/docker'

describe Gonzo::Providers::Docker do
  let(:subject) { Gonzo::Providers::Docker.new(config, {'project' => '/tmp', 'statedir' => '/tmp/.gonzo'}) }
  let(:config) do
    {
      'image'    => 'centos:centos7',
      'commands' => ['bundle exec rake spec_prep'],
      'env'      => {'SOMEVAR' => 'SOMEVAL'}
    }
  end

  before(:each) { allow(Gonzo).to receive(:required_command).and_return(nil) }

  it 'should format the provider configuration' do
    expect(subject.config).to include('default')
  end

  it 'should generate the shell script' do
    expect(subject.shell_script(config)).to match /bundle exec rake spec_prep/
    expect(subject.shell_script(config)).to match /export SOMEVAR="SOMEVAL"/
  end

  it 'should have the correct provider directories' do
    expect(subject.config).not_to be_empty
    expect(subject.global).not_to be_empty
    expect(subject.relative_providerdir).to match /\.gonzo\/provider\/docker/
  end
end
