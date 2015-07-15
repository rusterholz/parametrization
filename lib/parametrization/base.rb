require 'parametric'
require 'parametrization/config'

module Parametrization
  class Base < Parametric::Hash # A template for building a more-specific hash class (see https://github.com/ismasan/parametric#parametrichash)

    class_attribute :model_name, instance_writer: false
    class_attribute :whitelist,  instance_writer: false

    self.whitelist = [] # For safety, the base class allows no parameters through.

    def initialize( params )
      super( Parametrization.permit( params, whitelist, model_name ) )
      @params = @params.with_indifferent_access # After building the internal params hash, make it a little friendlier.
    end

    # If someone wants to convert a Parametrization::Base into a Hash (for example, when
    # passing params directly to an ActiveRecord .where method) this is the preferred way.
    def to_h
      @params.dup.with_indifferent_access
    end

    class << self # Parametrization::Base

      # Defines subclasses of Base, tailored to each set of attributes.
      def speciate!
        Parametrization::Config.attributes.each do |name,situations|
          situations.each do |sit,atts|
            block       = ( atts.last.is_a?( Proc ) && atts.pop ) # Note, pop is used here because the block should not be consumed by other methods later.
            class_name  = "#{name}_#{sit}_params".camelcase
            next if Parametrization.const_defined? class_name # Skip the rest of this loop if we've already built this class.
            class_name  = "::Parametrization::#{class_name}"
            method_name = sit == :default ? "#{name}_params" : "#{name}_params_for_#{sit}"
            Parametrization.instance_eval("
              class #{class_name} < ::Parametrization::Base
                #{build_param_calls_from( atts )}
              end
              @class_method_map[ '#{class_name}' ] = '#{method_name}'
            ")
            klass = class_name.constantize
            klass.model_name = name
            klass.whitelist  = if block
              klass.instance_eval &block            # If a block was included, execute it in the context of the new subclass,
              harvest_whitelist_from( klass, atts ) # then make sure the whitelist matches any changes made in the block.
            else atts                               # If no block was passed, the whitelist is the existing attributes list.
            end.dup.freeze                          # Ensure that the whitelist in the class cannot be altered via side-effects later.
          end
        end
      end

      # If a block was provided, any key that was defined in the block but omitted from the list
      # of atts should be added to the whitelist. If the configuration indicates a nested param
      # block (see https://github.com/ismasan/parametric#nested-structures) then we must recurse
      # to build the nested whitelist.
      def harvest_whitelist_from( klass, atts = [] )
        klass._allowed_params.each do |param,conf|
          next if atts.include? param
          # Note: Modifying the provided array is intentional here.
          if conf[ :multiple ]
            to_nest = { param => harvest_whitelist_from( conf[ :nested ] ) }
            if nest = atts.select{ |a| a.is_a? Hash }.last
              nest.merge(to_nest)
            else atts.push to_nest
            end
          else
            atts.push param
          end
        end
        atts
      end

      # This method builds ruby code, intended to be run inside the metaclass that the concern is
      # building, based on the list of atttributes passed in. As such, it is where most of the
      # interaction between the concern and the parametric gem happens.
      def build_param_calls_from( atts )
        atts.map do |att|
          case att
          when String, Symbol then "param :#{att}, '#{att}', nullable: true"
          when Hash
            att.map do |key,references|
              ( single = (references.last == Parametrization::Config::SINGLETON_FLAG) ) && references.pop # Remove the flag value if it is present.
              if references.empty? then "param :#{key}, '#{key}', nullable: true, multiple: true" # This handles explicit empty array literals.
              else [ "param :#{key}, '#{key}', nullable: true#{ single ? '' : ', multiple: true' } do", build_param_calls_from( references ), 'end' ]
              end
            end
          end
        end.flatten.join("\n")
      end

    end # of class << self
  end # of Base
end
