require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require_relative 'lib/gonzo/rake_tasks'
require_relative 'lib/gonzo/version'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task :bump do
  v = Gem::Version.new("#{Gonzo::VERSION}.0")
  s = <<-EOS
module Gonzo
  VERSION = '#{v.bump}'
end
EOS

  File.open('lib/gonzo/version.rb', 'w') do |file|
    file.print s
  end
  sh 'git add lib/gonzo/version.rb'
  sh "git commit -m 'Bump version'"
end

task :tag do
  v = Gonzo::VERSION
  tags = `git ls-remote --tags`.split("\t")

  unless tags.include?("refs/tags/#{v}\n")
    sh "git tag #{v}" unless `git tag`.split("\n").include?(v)
    sh 'git push origin --tags'
  end
end

task default: [:spec]
