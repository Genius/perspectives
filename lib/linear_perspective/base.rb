require 'forwardable'
require 'linear_perspective/macros'
require 'linear_perspective/templating'
require 'linear_perspective/properties'
require 'linear_perspective/memoization'
require 'linear_perspective/params'
require 'linear_perspective/context'
require 'linear_perspective/rendering'
require 'linear_perspective/caching'

module LinearPerspective
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
