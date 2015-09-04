require 'spec_helper'
require 'gonzo/providers/vagrant'

describe Gonzo::Providers::Vagrant do
  let(:subject) { Gonzo::Providers::Vagrant.new(config, {'project' => '/tmp', 'statedir' => '/tmp/.gonzo'}) }
  let(:config) do
    {
      'box' => 'puppetlabs/centos-7.0-64-puppet',
      'commands' => ['bundle exec rake spec_prep']
    }
  end

  it 'should format the provider configuration' do
    expect(subject.config).to include('default')
  end

  it 'should generate the shell script' do
    expect(subject.shellscript(config['commands'])).to match /bundle exec rake spec_prep/
    expect(subject.shellscript(config['commands'], {'SOMEVAR' => 'SOMEVAL'})).to match /export SOMEVAR="SOMEVAL"/
  end

  it 'should generate the vagrantfile' do
    expect(subject.vagrantfile).to match /config\.vm\.define :default do |default|/
    expect(subject.vagrantfile).to match /default\.vm\.box = \'puppetlabs\/centos-7\.0-64-puppet\'/
  end

  it 'should have the correct provider directories' do
    expect(subject.config).not_to be_empty
    expect(subject.global).not_to be_empty
    expect(subject.relative_providerdir).to match /\.gonzo\/provider\/vagrant/
  end
end
