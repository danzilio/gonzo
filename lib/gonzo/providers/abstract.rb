require 'fileutils'

module Gonzo
  module Providers
    class Abstract
      def shell_script(provider_config)
        script = []

        script << '#!/bin/bash'
        script << 'set -e'
        script << 'set -x'
        script << 'cp -r /gonzo /tmp/gonzo'
        script << 'cd /tmp/gonzo'

        if env = provider_config['env']
          env.each do |k,v|
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
    end
  end
end
