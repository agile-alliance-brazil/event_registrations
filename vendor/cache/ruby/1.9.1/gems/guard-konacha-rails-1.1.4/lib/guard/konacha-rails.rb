require 'guard/compat/plugin'
require 'rails'
require 'konacha'

module Guard
  class KonachaRails < Plugin
    require 'guard/konacha-rails/formatter'
    require 'guard/konacha-rails/runner'
    require 'guard/konacha-rails/server'

    attr_accessor :runner

    def initialize(options = {})
      super

      @runner = Guard::KonachaRails::Runner.new(options)
    end

    def start
      runner.start
    end

    def run_all
      runner.run
    end

    def run_on_changes(paths = [])
      runner.run(paths)
    end

    def self.template(plugin_location)
      File.read(template_path(plugin_location))
    end

    def self.template_path(plugin_location)
      # workaround because Guard discards the '-' when detecting template path
      File.join(plugin_location, 'lib', 'guard', 'konacha-rails', 'templates', 'Guardfile')
    end
  end
end
