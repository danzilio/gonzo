require 'gonzo/providers/abstract'

module Gonzo
  module Providers
    class Docker < Gonzo::Providers::Abstract
      attr_accessor :exit_codes
      attr_reader :config, :providerdir, :global

      def initialize(config, global)
        @exit_codes = []
        @global = global
        @providerdir = "#{global['statedir']}/provider/docker"

        Gonzo.required_command 'docker'

        if config.keys.include?('image')
          @config = { 'default' => config }
        else
          @config = config
        end
      end

      def run
        setup
        config.each do |container, container_config|
          exit_codes << provision(container, container_config)
        end

        !exit_codes.include?(false)
      end

      private

      def provision_command(container, container_config)
        command = ['docker', 'run', "-h #{container}", "-v #{Dir.pwd}:/gonzo"]
        command << "-u #{container_config['user']}" if container_config['user']
        command << "#{container_config['image']} /bin/bash /gonzo/#{relative_providerdir}/#{container}.sh"
        command.join(' ')
      end
    end
  end
end
