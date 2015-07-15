module Parametrization
  class Config # Holds the configuration state. The block from the config file is executed in the context of this class.

    DEFAULT_CONFIG_PATH = %w(config parametrization.rb)
    SINGLETON_FLAG      = :__parametrization_singleton!

    class << self # Config

      # Format: { name: { situation: [ :args, :that, :could, be: [ :passed, :to ], :permit ] } }
      attr_reader :attributes

      # The primary method to call from the configuration file.
      def attributes_for( name, args = [], &block )
        @attributes ||= {}
        if name.is_a? Hash
          name.each do |n,atts|
            attributes_for( n, atts ) if atts.is_a? Array
          end
        else
          @attributes[ n = name.to_sym ] ||= {}
          @attributes[ n ].merge!( default: args.flatten ) if args.present?
          @attributes[ n ].merge!( Evaluator.new( block ).attributes ) if block_given?
        end
      end

      # Looks for nested attribute references and resolves them into canonical forms.
      #
      # NOTE: you shouldn't abuse the config file with a circular dependency of nested references, but if you
      # do, this will probably build a hash with circular references. I have no idea what will happen if a
      # circular hash gets passed to .permit (probably a SystemStackError), so do this at your own peril.
      #
      # You shouldn't ever need to call this from the config file, but you could if for some reason you
      # needed to force a reference to resolve before further configuration.
      def resolve!
        @attributes.each do |model,situations|
          situations.each do |sit,atts|
            atts.select{ |a| a.is_a? Hash }.each do |h|
              h.each do |key,reference|
                next unless reference.is_a?( Symbol )

                # Detect the ! that indicates a singly-nested model, and remove it if present.
                reference = reference.to_s.gsub!( /!$/, '' ).to_sym if ( single = !!(/!$/.match( reference.to_s )) )

                if ( matches = /([a-z_]+)_for_([a-z_]+)/.match( reference.to_s ) ) && @attributes[ matches[1].to_sym ].present?
                  h[ key ] = @attributes[ matches[1].to_sym ][ matches[2].to_sym ] || []
                  h[ key ] << SINGLETON_FLAG if single
                elsif @attributes[ reference ].present?
                  h[ key ] = @attributes[ reference ][ :default ] || []
                  h[ key ] << SINGLETON_FLAG if single
                end

              end
            end
          end
        end
      end # of resolve!

    end # of class << self

    class Evaluator # A simple PORO to read the DSL inside an attributes_for block.
      attr_reader :attributes
      def initialize( block )
        @attributes = {}
        instance_eval(&block)
      end
      def method_missing( meth, *args, &block ) # This is the method that handles reading the configuration for a single situation.
        @attributes[ meth.to_sym ] = args.flatten
        @attributes[ meth.to_sym ] << block if block.present?
      end
      def respond_to?(*_) # Since we implement a global method_missing, it's polite to implement a global respond_to?.
        true
      end
    end

  end # of Config
end
