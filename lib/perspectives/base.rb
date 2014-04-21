require 'forwardable'
require 'perspectives/templating'
require 'perspectives/properties'
require 'perspectives/memoization'
require 'perspectives/params'
require 'perspectives/context'
require 'perspectives/rendering'
require 'perspectives/caching'

module Perspectives
  class Base
    include Templating
    include Properties
    include Memoization
    include Params
    include Context
    include Rendering
    include Caching

    class << self
      def inherited(base)
        base.__send__(:filename=, caller.first[/^(.*?.rb):\d/, 1])
      end

      private

      attr_accessor :filename
    end
  end
end
