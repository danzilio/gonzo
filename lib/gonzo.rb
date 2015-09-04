require 'gonzo/runner'

module Gonzo
  def self.config(path = '.')
    return @config if @config
    project = File.expand_path(path)
    config_file = File.join(project, '.gonzo.yml')
    fail "No .gonzo.yml found in #{project}!" unless File.exist?(config_file)
    data = YAML.load_file(config_file)
    data['gonzo'] = global_defaults.merge data['gonzo'] || {}
    data['gonzo']['project'] = project
    data['gonzo']['statedir'] = "#{project}/.gonzo"
    @config = data
  end

  def self.reload!
    @config = nil
  end

  def self.global_defaults
    {
      'stop_on_failure' => false,
      'cleanup' => true
    }
  end
end
