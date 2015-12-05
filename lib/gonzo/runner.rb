require 'yaml'
require 'fileutils'

module Gonzo
  class InvalidProvider < StandardError; end
  class ProviderNotFound < StandardError; end
  class Runner
    attr_accessor :exit_codes
    attr_reader :config, :global

    def initialize(config)
      @exit_codes = []
      @config = config
      @global = config['gonzo']
    end

    def run
      providers.each do |provider|
        exit_codes << run_provider(provider)
      end

      cleanup unless global['cleanup'] == false
      exit exit_codes.include?(false) ? false : true
    end

    private

    def cleanup
      providers.each(&:cleanup)
      FileUtils.rm_r global['statedir']
    end

    def providers
      return @providers if @providers
      @providers = []
      config.select { |k, _v| k unless k == 'gonzo' }.each do |provider, conf|
        @providers << get_provider(provider).new(conf, global)
      end
      @providers
    end

    def get_provider(provider)
      fail InvalidProvider, 'Abstract provider called!' if provider == 'abstract'
      begin
        require "gonzo/providers/#{provider}"
        return Object.const_get("Gonzo::Providers::#{provider.capitalize}")
      rescue LoadError
        raise ProviderNotFound, "Gonzo provider #{provider} was not found!"
      end
    end

    def run_provider(provider)
      status = provider.run

      exit status unless status if config['gonzo']['stop_on_failure']

      status
    end
  end
end
