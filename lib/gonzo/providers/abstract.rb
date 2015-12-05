require 'fileutils'

module Gonzo
  module Providers
    class Abstract
      def script_header
        [
          '#!/bin/bash',
          'set -e',
          'set -x',
          'cp -r /gonzo /tmp/gonzo',
          'cd /tmp/gonzo'
        ]
      end

      def setup
        FileUtils.mkdir_p(providerdir) unless File.directory?(providerdir)
      end

      def shell_script(provider_config)
        script = script_header

        if (env = provider_config['env'])
          env.each do |k, v|
            script << "export #{k}=\"#{v}\""
          end
        end

        provider_config['commands'].each do |command|
          script << command
        end

        script.join("\n")
      end

      def cleanup
        FileUtils.rm_rf providerdir
      end

      def relative_providerdir
        (providerdir.split('/') - global['project'].split('/')).join('/')
      end

      def provision(vm, config)
        fail "No provisioner commands given for #{vm}!" unless config['commands']
        local_script = "#{providerdir}/#{vm}.sh"
        File.open(local_script, 'w') do |f|
          f << shell_script(config)
        end
        FileUtils.chmod('+x', local_script)
        system provision_command(vm, config)
      end
    end
  end
end
