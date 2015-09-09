require 'gonzo/providers/abstract'

module Gonzo
  module Providers
    class Docker < Gonzo::Providers::Abstract
      attr_reader :config, :providerdir, :global

      def initialize(config, global)
        @global = global
        @providerdir = "#{global['statedir']}/provider/docker"

        Gonzo.required_command 'docker'

        if config.keys.include?('image')
          @config = { 'default' => config }
        else
          @config = config
        end
      end

      def provision(container, container_config)
        FileUtils.mkdir_p(providerdir) unless File.directory?(providerdir)
        local_script = "#{providerdir}/#{container}.sh"
        relative_script = "#{relative_providerdir}/#{container}.sh"
        if container_config['commands']
          command = ['docker', 'run', "-v #{Dir.pwd}:/gonzo"]
          command << "-u #{container_config['user']}" if container_config['user']
          File.open(local_script, 'w') do |f|
            f << shellscript(container_config)
          end
          FileUtils.chmod('+x', local_script)
          command << "#{container_config['image']} /bin/bash /gonzo/#{relative_script}"
          system command.join(' ')
        else
          fail "No provisioner commands given for #{container}!"
        end
      end

      def run
        exit_codes = []
        config.each do |container, container_config|
          exit_codes << provision(container, container_config)
        end

        return false if exit_codes.include?(false)
        true
      end
    end
  end
end
