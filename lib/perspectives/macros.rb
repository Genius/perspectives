module Perspectives
  module Macros
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def config_attribute(*attr_names)
        attr_names.each(&method(:setup_config_attribute))
      end

      private

      def setup_config_attribute(attr_name)
        name = attr_name.to_sym
        ivar = :"@#{name}"

        self.singleton_class.__send__(:define_method, name) do
          if instance_variable_defined?(ivar)
            instance_variable_get(ivar)
          elsif superclass.respond_to?(name)
            instance_variable_set(ivar, superclass.__send__(name))
          end
        end

        self.singleton_class.__send__(:define_method, :"#{name}=") do |value|
          instance_variable_set(ivar, value)
        end

        delegate name, to: 'self.class'
      end
    end
  end
end
