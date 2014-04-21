module Perspectives
  module Inputs
    def self.included(base)
      base.class_eval do
        extend ClassMethods

        class_attribute :_required_inputs, :_optional_inputs
        self._required_inputs = []
        self._optional_inputs = []
        attr_reader :_inputs, :context
      end
    end

    def initialize(context = {}, inputs = {})
      raise ArgumentError, "Inputs is not a hash!" unless inputs.is_a?(Hash)
      @_inputs = inputs.symbolize_keys
      @context = context
      assert_valid_inputs!
    end

    private

    def assert_valid_inputs!
      missing = _required_inputs.select { |l| !_inputs.key?(l) }
      unknown = _inputs.keys - (_required_inputs + _optional_inputs)

      if missing.any?
        raise ArgumentError, "Missing #{missing.join(', ').inspect} while initializing #{self.class}!"
      elsif unknown.any?
        raise ArgumentError, "Unrecognized inputs #{unknown.join(', ').inspect} while initializing #{self.class}!"
      end
    end

    module ClassMethods
      def input(*input_names)
        options = input_names.extract_options!

        if options[:allow_nil]
          self._optional_inputs += input_names
        else
          self._required_inputs += input_names
        end

        input_names.each { |n| define_method(n) { _inputs[n] } }
      end
    end
  end
end
