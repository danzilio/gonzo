require_relative 'lib/gonzo/version'

Gem::Specification.new do |s|
  s.name        = 'gonzo'
  s.version     = Gonzo::VERSION
  s.licenses    = ['Apache-2.0']
  s.summary     = 'A simpler Muppet for simpler Puppets'
  s.description = <<-EOD
    This Gem lets you programmatically spin up a Vagrant box and run a set of
    commands in the root of your project. This can be useful for running RSpec
    or ServerSpec tests.
  EOD
  s.authors     = ['David Danzilio']
  s.email       = 'david@danzilio.net'

  s.files       = Dir['README.md', "bin/*", "lib/**/*"]
  s.homepage    = 'https://github.com/danzilio/gonzo'
  s.executables = ['gonzo']

  s.add_runtime_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 2.0'
end
