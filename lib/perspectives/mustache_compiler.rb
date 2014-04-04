# somewhat ganked from https://github.com/railsware/smt_rails/blob/7d63a3d5c838881690d365f41f45b9082c2611c8/lib/smt_rails/tilt.rb

require 'tilt'

module Perspectives
  class MustacheCompiler < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def prepare
    end

    def evaluate(scope, locals, &block)
      namespace = "this.#{Perspectives.template_namespace}"

      <<-MustacheTemplate
        (function() {
        #{namespace} || (#{namespace} = {});

        var data = #{data.inspect}

        Mustache.parse(data)

        #{namespace}[#{scope.logical_path.inspect}] = function(object) {
          if (!object){ object = {}; }
          return Mustache.render(data, object)
        };
        }).call(this);
      MustacheTemplate
    end
  end
end
