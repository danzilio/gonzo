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

  describe '.run' do
    context 'with a valid provider' do
      before do
        allow(Gonzo).to receive(:required_command).and_return(nil)
        allow(subject).to receive(:cleanup).and_return(nil)
        allow_any_instance_of(Gonzo::Providers::Vagrant).to receive(:run).and_return(exit_status)
      end

      context 'when successful' do
        let(:exit_status) { true }
        it 'should exit 0' do
          begin
            subject.run
          rescue SystemExit => e
            expect(e.status).to eq(0)
          end
        end
      end

      context 'when unsuccessful' do
        let(:exit_status) { false }
        it 'should exit 1' do
          begin
            subject.run
          rescue SystemExit => e
            expect(e.status).to eq(1)
          end
        end
      end
    end

    context 'with an invalid provider' do
      let(:config) { { 'fubar' => { 'foo' => 'bar' } } }
      it 'should raise a ProviderNotFound' do
        expect { subject.run }.to raise_error Gonzo::ProviderNotFound
      end
    end

    context 'with the abstract provider' do
      let(:config) { { 'abstract' => { 'foo' => 'bar' } } }
      it 'should raise a InvalidProvider' do
        expect { subject.run }.to raise_error Gonzo::InvalidProvider
      end
    end
  end
end
