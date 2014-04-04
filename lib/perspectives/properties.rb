module Perspectives
  module Properties
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        config_attribute :_properties, :_nested_perspectives

        self._properties = []
        self._nested_perspectives = []
      end
    end

    private

    def _property_map
      _properties.each_with_object({}) { |p, h| h[p] = __send__(p) }
    end

    def _resolve_partial_class_name(name)
      Perspectives.resolve_partial_class_name(self.class.to_s.split('::').first, name)
    end

    module ClassMethods
      def property(name, *names, &block)
        unless names.empty?
          raise ArgumentError, "Can't define multiple properties and pass a block" if block_given?
          return names.push(name).each(&public_method(:property))
        end

        self._properties += [name]

        unless method_defined?(name)
          raise ArgumentError, "No method #{name} and no block given" unless block_given?

          define_method(name, &block)
        end
      end

      def nested(name, locals = {}, &block)
        _setup_nested(name, locals, {}, &block)
      end

      def nested_collection(name, *args, &block)
        options = args.extract_options!
        collection = options.fetch(:collection, args.first)
        raise ArgumentError, "You must either pass in a collection, or pass a collection option" unless collection

        _setup_nested(name, options.fetch(:locals, {}), options.merge!(:collection => collection), &block)
      end

      def delegate_property(*props, opts)
        to = opts.fetch(:to) { raise ArgumentError, "delegate_property requires something to delegate to!" }

        def_delegators to, *props
        props.each(&public_method(:property))
      end

      private

      def _setup_nested(name, locals, options, &block)
        name_str, name_sym = name.to_s, name.to_sym

        prop_name = options.fetch(:property, _default_property_name(name_str, options)).to_sym

        unless block_given? || method_defined?(prop_name)
          local_procs = locals.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.to_proc }
          nested_klass_ivar = :"@_#{name_str.underscore.gsub('/', '__')}_klass"

          define_method(prop_name) do
            klass =
              if self.class.instance_variable_defined?(nested_klass_ivar)
                self.class.instance_variable_get(nested_klass_ivar)
              else
                self.class.instance_variable_set(nested_klass_ivar, _resolve_partial_class_name(name))
              end

            realized_locals = local_procs.each_with_object({}) { |(k, v), h| h[k] = instance_exec(self, &v) }

            if options.key?(:collection)
              collection = instance_exec(self, &options[:collection])
              return unless collection.present?

              as = options.fetch(:as, collection.first.class.base_class.name.downcase).to_sym
              Collection.new(collection.map { |o| klass.new(context, realized_locals.merge(as => o)) })
            else
              klass.new(context, realized_locals)
            end
          end
        end

        property(prop_name, &block)
        self._nested_perspectives += [prop_name]
      end

      def _default_property_name(name_str, options)
        name = name_str.split('/').last
        name = name.pluralize if options.key?(:collection)
        name
      end
    end
  end
end
