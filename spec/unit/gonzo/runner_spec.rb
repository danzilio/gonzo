require 'spec_helper'
require 'gonzo/runner'

describe Gonzo::Runner do
  let(:subject) { Gonzo::Runner.new(config) }
  let(:config) do
    {
      'gonzo'   => { 'statedir' => '/tmp/.gonzo' },
      'vagrant' => {
        'box' => 'puppetlabs/centos-7.0-64-puppet',
        'commands' => ['bundle exec rake spec_prep']
      }
    }
  end

  it 'should load the configuration' do
    expect(subject.config).to include('gonzo')
    expect(subject.global).to include('statedir')
  end

  describe '.providers' do
    it 'should return an array of provider objects' do
      allow(Gonzo).to receive(:required_command).and_return(nil)
      expect(subject.providers).to be_a Array
      subject.providers.each do |prov|
        expect(prov).to be_a Gonzo::Providers::Vagrant
      end
    end
  end
end
