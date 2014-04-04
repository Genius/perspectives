module Perspectives
  module Memoization
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def property(name, *names, &block)
        super.tap { memoize_property(name) if names.empty? }
      end

      def memoize_property(prop_name)
        raise ArgumentError, "No method #{prop_name}" unless method_defined?(prop_name)

        ivar = "@_memoized_#{prop_name}"

        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{prop_name}_with_memoization             # def name_with_memoization
            return #{ivar} if defined?(#{ivar})         # return @_memoized_name if defined?(@_memoized_name)
            #{ivar} = #{prop_name}_without_memoization  # @_memoized_name = name_without_memoization
          end
        CODE
        alias_method :"#{prop_name}_without_memoization", prop_name
        alias_method prop_name, :"#{prop_name}_with_memoization"
      end
    end
  end
end
