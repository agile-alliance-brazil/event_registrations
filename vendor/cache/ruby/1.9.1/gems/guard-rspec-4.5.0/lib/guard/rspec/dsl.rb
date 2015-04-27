require "ostruct"

require "guard/rspec"

module Guard
  class RSpec < Plugin
    class Dsl
      def initialize(dsl)
        @dsl = dsl
      end

      def watch_spec_files_for(expr)
        @dsl.send(:watch, expr) { |m| rspec.spec.(m[1]) }
      end

      def rspec
        @rspec ||= OpenStruct.new(to_s: "spec").tap do |rspec|
          rspec.spec_dir = "spec"
          rspec.spec = ->(m) { "#{rspec.spec_dir}/#{m}_spec.rb" }
          rspec.spec_helper = "#{rspec.spec_dir}/spec_helper.rb"
          rspec.spec_files = %r{^#{rspec.spec_dir}/.+_spec\.rb$}
          rspec.spec_support = %r{^#{rspec.spec_dir}/support/(.+)\.rb$}
        end
      end

      def ruby
        # Ruby apps
        @ruby || OpenStruct.new.tap do |ruby|
          ruby.lib_files = %r{^(lib/.+)\.rb$}
        end
      end

      def rails(options = {})
        # Rails example
        @rails ||= OpenStruct.new.tap do |rails|
          exts = options.dup.delete(:view_extensions) || %w(erb haml slim)

          rails.app_files = %r{^app/(.+)\.rb$}

          rails.views = %r{^app/(views/.+/[^/]*\.(?:#{exts * "|"}))$}
          rails.view_dirs = %r{^app/views/(.+)/[^/]*\.(?:#{exts * "|"})$}
          rails.layouts = %r{^app/layouts/(.+)/.*\.("#{exts * "|"}")$}

          rails.controllers = %r{^app/controllers/(.+)_controller\.rb$}
          rails.routes = "config/routes.rb"
          rails.app_controller = "app/controllers/application_controller.rb"
          rails.spec_helper = "#{rspec.spec_dir}/rails_helper.rb"
        end
      end
    end
  end
end
