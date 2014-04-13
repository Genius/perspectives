module Perspectives
  module Params
    def self.included(base)
      base.class_eval do
        extend ClassMethods

        config_attribute :_required_params
        self._required_params = []
        attr_reader :_params, :context
      end
    end

    def initialize(context, params)
      raise ArgumentError, "Params is not a hash!" unless params.is_a?(Hash)
      @_params = params
      @context = context
      assert_valid_params!
    end

    private

    def assert_valid_params!
      missing = _required_params.select { |l| !_params.key?(l) }

      if missing.any?
        raise ArgumentError, "Missing #{missing.join(', ').inspect} while initializing #{self.class}!"
      end
    end

    module ClassMethods
      def param(*param_names)
        options = param_names.extract_options!

        self._required_params += param_names unless options[:allow_nil]
        param_names.each { |n| define_method(n) { _params[n] } }
      end
    end
  end
end
