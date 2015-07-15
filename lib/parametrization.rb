module Parametrization

  #
  # "Parametrization is the process of deciding and defining the parameters necessary
  # for a complete or relevant specification of a model." -- Wikipedia
  #

  extend ActiveSupport::Concern

  module ClassMethods
  end

  included do
    Parametrization.load_configuration!      # Make sure we have a configuration.
    Parametrization.build_shortcuts_on self  # Here, `self` is the class on which this concern has been included.
  end

end

require 'parametrization/version'
require 'parametrization/config'
require 'parametrization/base'
require 'parametrization/class_methods'


