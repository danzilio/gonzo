require 'gonzo/providers/abstract'

module Gonzo
  module Providers
    class Vagrant < Gonzo::Providers::Abstract
      attr_accessor :exit_codes
      attr_reader :config, :providerdir, :global

      def initialize(config, global)
        @exit_codes = []
        @global = global
        @providerdir = "#{global['statedir']}/provider/vagrant"

        Gonzo.required_command 'vagrant'

        if config.keys.include?('box')
          @config = { 'default' => config }
        else
          @config = config
        end
      end

      def provision_command(box, box_config)
        command = []
        command << "vagrant ssh #{box} -c"
        command << 'sudo' if box_config['sudo']
        command << "/gonzo/#{relative_providerdir}/#{box}.sh"
        command.join(' ')
      end

      def vagrantfile
        vf = [
          'VAGRANTFILE_API_VERSION = "2"',
          'Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|'
        ]

        config.each do |name, conf|
          vf += vm_definition(name, conf)
        end

        vf << 'end'

        vf.join("\n")
      end

      def cleanup
        FileUtils.rm_rf File.join(global['project'], '.vagrant')
        FileUtils.rm_rf 'Vagrantfile'
        super
      end

      def run_box(box, box_config)
        up(box)
        begin
          exit_codes << provision(box, box_config)
        # We want to catch all exceptions here so we make sure we don't leave a VM hanging
        rescue Exception => e # rubocop:disable Lint/RescueException
          puts 'Vagrant exception caught! Cleaning up.'
          down(box)
          puts e
          return false
        end
        down(box)
      end

      def run
        setup
        config.each do |box, box_config|
          run_box(box, box_config)
        end
        !exit_codes.include?(false)
      end

      private

      def setup
        super
        File.open('Vagrantfile', 'w') do |f|
          f << vagrantfile
        end
      end

      def vm_definition(name, conf)
        section = []
        section << "  config.vm.define :#{name} do |#{name}|"
        section << "    #{name}.vm.box = '#{conf['box']}'"
        section << "    #{name}.vm.box_url = '#{conf['box_url']}'" if conf['box_url']
        section << "    #{name}.vm.synced_folder '.', '/gonzo'"
        section << '  end'
        section
      end

      def up(box)
        system "vagrant up #{box}"
      end

      def down(box)
        system "vagrant destroy -f #{box}"
      end
    end
  end
end
