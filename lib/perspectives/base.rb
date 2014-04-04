require 'forwardable'
require 'perspectives/macros'
require 'perspectives/templating'
require 'perspectives/properties'
require 'perspectives/memoization'
require 'perspectives/params'
require 'perspectives/context'
require 'perspectives/rendering'
require 'perspectives/caching'

module Perspectives
  class Base
    extend Forwardable

    include Macros
    include Templating
    include Properties
    include Memoization
    include Params
    include Context
    include Rendering
    include Caching
  end
end
