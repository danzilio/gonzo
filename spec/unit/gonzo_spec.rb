require 'spec_helper'
require 'gonzo'

describe Gonzo do
  let(:subject) { Gonzo.config(fixture_path) }
  it 'should load the configuration file' do
    expect(subject).to be_a Hash
    expect(subject).not_to be_empty
    expect(subject).to include('gonzo', 'vagrant')
    expect(subject['gonzo']['stop_on_failure']).to be true
  end

  it 'should have our defaults' do
    expect(subject['gonzo']['project']).to match(/#{fixture_path}/)
    expect(subject['gonzo']['statedir']).to match(%r{#{fixture_path}/\.gonzo})
  end
end
