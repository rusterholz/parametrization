require 'rails/generators'
require 'parametrization'
require 'parametrization/config'

module Parametrization
  module Generators
    class ConfigGenerator < Rails::Generators::Base

      source_root File.expand_path( '../templates', __FILE__ )

      def generate_config
        copy_file 'config.rb', Parametrization::Config::DEFAULT_CONFIG_PATH.join( File::SEPARATOR )
      end

    end
  end
end

