module Perspectives
  module Params
    def self.included(base)
      base.class_eval do
        extend ClassMethods

        class_attribute :_required_params, :_optional_params
        self._required_params = []
        self._optional_params = []
        attr_reader :_params, :context
      end
    end

    def initialize(context = {}, params = {})
      raise ArgumentError, "Params is not a hash!" unless params.is_a?(Hash)
      @_params = params.symbolize_keys
      @context = context
      assert_valid_params!
    end

    private

    def assert_valid_params!
      missing = _required_params.select { |l| !_params.key?(l) }
      unknown = _params.keys - (_required_params + _optional_params)

      if missing.any?
        raise ArgumentError, "Missing #{missing.join(', ').inspect} while initializing #{self.class}!"
      elsif unknown.any?
        raise ArgumentError, "Unrecognized params #{unknown.join(', ').inspect} while initializing #{self.class}!"
      end
    end

    module ClassMethods
      def param(*param_names)
        options = param_names.extract_options!

        if options[:allow_nil]
          self._optional_params += param_names
        else
          self._required_params += param_names
        end

        param_names.each { |n| define_method(n) { _params[n] } }
      end
    end
  end
end
