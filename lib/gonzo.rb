require 'gonzo/runner'

module Gonzo
  class << self
    def config(path = '.')
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

    def reload!
      @config = nil
    end

    def global_defaults
      {
        'stop_on_failure' => false,
        'cleanup' => true
      }
    end

    def required_command(cmd)
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        bin = File.join(path, cmd)
        return nil if File.executable?(bin) && !File.directory?(bin)
      end

      fail "Required command #{cmd} not found in $PATH!"
    end
  end
end
