module Perspectives
  module Context
    def respond_to?(method, include_private = false)
      super || context.key?(method)
    end

    private

    def method_missing(method, *args, &block)
      if args.empty? && !block_given? && context.key?(method)
        self.class.__send__(:define_method, method) { __send__(:context).fetch(method) }
        __send__(method)
      else
        super
      end
    end
  end
end
