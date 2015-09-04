Gem::Specification.new do |s|
  s.name        = 'gonzo'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.summary     = 'A simpler Muppet for simpler Puppets'
  s.description = <<-EOD
    This Gem lets you programmatically spin up a Vagrant box and run a set of
    commands in the root of your project. This can be useful for running RSpec
    or ServerSpec tests.
  EOD
  s.authors     = ['David Danzilio']
  s.files       = Dir["lib/**/*"]
  s.homepage    = 'https://github.com/danzilio/gonzo'
end
