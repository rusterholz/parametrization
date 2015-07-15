require 'parametrization/config'
require 'parametrization/base'

module Parametrization
  class << self # Parametrization

    attr_reader :configured
    attr_reader :class_method_map

    # The configuration file should consist of calling this method and passing the configuration block
    # to it. You can call it more than once if you like (e.g. by requiring other configuration files),
    # but you should be aware that if a later call attempts to redefine (change) a particular situation
    # for a particular model, that change will be IGNORED by this concern. Only NEW situations / models
    # will be picked up by subsequent calls to this method.
    def configure( &block )
      @class_method_map ||= {}
      Parametrization.patch!
      Parametrization::Config.instance_eval(&block)
      Parametrization::Config.resolve!
      Parametrization::Base.speciate!
      @configured = true
    end

    def patch!
      unless @configured # This should only be run once, no matter how many times .configure is called.
        Parametric::Hash.instance_eval do
          # The following delegators are required in order for Parametric::Hash to behave more like
          # a Hash for ActiveRecord's usage, but they are absent from the list in the gem's source
          # code (https://github.com/ismasan/parametric/blob/master/lib/parametric/hash.rb). So we
          # monkey-patch that class PRIOR to reading any configuration. Note that this cannot be
          # run on Parametrization::Base, because the gem builds several anonymous internal classes
          # which inherit from Parametric::Hash and which Rails expects to have these methods.
          def_delegators :params, :all?, :any?, :except!, :except, :include?, :member?, :reject!, :reject, :stringify_keys, :with_indifferent_access
        end
      end
    end

    # We route the params through this method on their way into the hash class, which filters
    # them through Rails' strong parameters. It also replicates a small amount of normalization
    # logic from PermittedParams.
    def permit( params, whitelist, name = nil )
      raise 'Parametrization not yet configured' unless @configured
      whitelist ||= []
      px = params.respond_to?( :permit ) ? params : ActionController::Parameters.new( params )
      px = px[ name ] if( name && px.has_key?( name ) && px[ name ].is_a?( Hash ) )
      px.permit( *whitelist )
    end

    # Define shortcut methods in the including class that build and return instances of the
    # various hash classes (see below). Due to the dynamic nature of this concern, this
    # can't be done via simple module inclusion -- it has to be done on each controller class.
    def build_shortcuts_on( controller_class )
      @class_method_map.each do |klass,meth|
        k = klass.constantize
        controller_class.send( :define_method, meth ){ k.new( params ) }
      end
    end

    # Attempts to load a configuration file from the default location if not already configured.
    def load_configuration!
      unless @configured
        load Rails.root.join( *Parametrization::Config::DEFAULT_CONFIG_PATH )
      end
    end


  end
end
