require 'forwardable'
require 'perspectives/templating'
require 'perspectives/outputs'
require 'perspectives/memoization'
require 'perspectives/inputs'
require 'perspectives/context'
require 'perspectives/rendering'
require 'perspectives/caching'

module Perspectives
  class Base
    include Templating
    include Outputs
    include Memoization
    include Inputs
    include Context
    include Rendering
    include Caching

    class << self
      alias_method :param, :input
      alias_method :property, :output
      alias_method :delegate_property, :delegate_output
    end

    class << self
      def inherited(base)
        base.__send__(:filename=, caller.first[/^(.*?.rb):\d/, 1])
      end

      private

      attr_accessor :filename
    end
  end
end
