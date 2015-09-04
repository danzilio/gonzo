require 'rake'
require 'gonzo'
require 'rake/tasklib'

desc "Run Gonzo"
task :gonzo do
  config = Gonzo.config(Dir.pwd)
  gonzo = Gonzo::Runner.new(config)
  gonzo.run
end
