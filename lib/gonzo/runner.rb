require 'yaml'
require 'fileutils'
require 'gonzo/providers'

module Gonzo
  class Runner
    attr_reader :statedir, :config, :global

    def initialize(config)
      @config = config
      @global = config['gonzo']
    end

    def supported_providers
      %w(vagrant)
    end

    def providers
      return @providers if @providers
      @providers = []
      provs = config.select { |k,v| k unless k == 'gonzo' }
      provs.each do |provider,config|
        unless supported_providers.include?(provider)
          puts "Provider #{provider} is not implemented!"
          break
        end
        @providers << Gonzo::Providers::Vagrant.new(config, global)
      end
      @providers
    end

    def cleanup
      return if global['cleanup'] == false
      providers.each(&:cleanup)
      FileUtils.rm_r global['statedir']
    end

    def run
      exit_codes = []
      providers.each do |provider|
        status = provider.run

        exit_codes << status

        if config['gonzo']['stop_on_failure']
          exit status unless status
        end
      end

      status = exit_codes.include?(false) ? false : true
      cleanup
      exit status
    end
  end
end
