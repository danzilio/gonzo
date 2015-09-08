require 'fileutils'

module Gonzo
  module Providers
    class Docker
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

      def cleanup
        true
      end

      def shellscript(container_config)
        script = []

        script << '#!/bin/bash'
        script << 'set -e'
        script << 'set -x'
        script << 'cp -r /gonzo /tmp/gonzo'
        script << 'cd /tmp/gonzo'

        if env = container_config['env']
          env.each do |k,v|
            script << "export #{k}=\"#{v}\""
          end
        end

        container_config['commands'].each do |command|
          script << command
        end

        script.join("\n")
      end

      def relative_providerdir
        (providerdir.split('/') - global['project'].split('/')).join('/')
      end

      def provision(container, container_config)
        FileUtils.mkdir_p(providerdir) unless File.directory?(providerdir)
        local_script = "#{providerdir}/#{container}.sh"
        relative_script = "#{relative_providerdir}/#{container}.sh"
        if container_config['commands']
          File.open(local_script, 'w') do |f|
            f << shellscript(container_config)
          end
          FileUtils.chmod('+x', local_script)
          system "docker run -v '#{Dir.pwd}:/gonzo' #{container_config['image']} /bin/bash /gonzo/#{relative_script}"
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
