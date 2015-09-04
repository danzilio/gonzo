require 'fileutils'

module Gonzo
  module Providers
    class Vagrant
      attr_reader :config, :providerdir, :global

      def initialize(config, global)
        @global = global
        @providerdir = "#{global['statedir']}/provider/vagrant"

        if config.keys.include?('box')
          @config = { 'default' => config }
        else
          @config = config
        end
      end

      def cleanup
        FileUtils.rm_rf File.join(global['project'], '.vagrant')
        FileUtils.rm_rf 'Vagrantfile'
      end

      def shellscript(box_config)
        script = []

        script << '#!/bin/bash'
        script << 'set -e'
        script << 'set -x'
        script << 'cp -r /vagrant /tmp/gonzo'
        script << 'cd /tmp/gonzo'

        if env = box_config['env']
          env.each do |k,v|
            script << "export #{k}=\"#{v}\""
          end
        end

        box_config['commands'].each do |command|
          script << command
        end

        script.join("\n")
      end

      def vagrantfile
        vf = []

        vf << 'VAGRANTFILE_API_VERSION = "2"'
        vf << 'Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|'

        config.each do |name,conf|
          vf << "  config.vm.define :#{name} do |#{name}|"
          vf << "    #{name}.vm.box = '#{conf['box']}'"
          vf << "    #{name}.vm.box_url = '#{conf['box_url']}'" if conf['box_url']
          vf << '  end'
        end

        vf << 'end'

        vf.join("\n")
      end

      def up(box)
        File.open('Vagrantfile', 'w') do |f|
          f << vagrantfile
        end
        system "vagrant up #{box}"
      end

      def relative_providerdir
        (providerdir.split('/') - global['project'].split('/')).join('/')
      end

      def provision(box, box_config)
        FileUtils.mkdir_p(providerdir) unless File.directory?(providerdir)
        local_script = "#{providerdir}/#{box}.sh"
        relative_script = "#{relative_providerdir}/#{box}.sh"
        if box_config['commands']
          File.open(local_script, 'w') do |f|
            f << shellscript(box_config)
          end
          FileUtils.chmod('+x', local_script)
          command = box_config['sudo'] ? "'sudo /vagrant/#{relative_script}'" : "/vagrant/#{relative_script}"
          system "vagrant ssh #{box} -c #{command}"
        else
          fail "No provisioner commands given for #{box}!"
        end
      end

      def down(box)
        system "vagrant destroy -f #{box}"
      end

      def run
        exit_codes = []
        config.each do |box, box_config|
          up(box)

          begin
            exit_codes << provision(box, box_config)
          rescue Exception => e           # We want to catch all exceptions here so we make sure we don't leave a VM hanging
            puts "Exception caught! Cleaning up."
            down(box)
            puts e
            return false
          end

          down(box)
        end

        return false if exit_codes.include?(false)
        true
      end
    end
  end
end
