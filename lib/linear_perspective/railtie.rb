require 'linear_perspective/controller_additions'
require 'linear_perspective/responder'

module LinearPerspective
  class Railtie < Rails::Railtie
    initializer 'linear_perspective.railtie' do |app|
      app.config.autoload_paths += ['app/perspectives']
      app.config.watchable_dirs['app/mustaches'] = [:mustache]

      app.config.assets.paths << File.expand_path('../../../vendor/assets/javascripts', __FILE__)

      LinearPerspective::Base.class_eval do
        include app.routes.url_helpers
        include ERB::Util
      end

      LinearPerspective.configure do |c|
        c.template_path = app.root.join('app', 'mustaches')
        c.raise_on_context_miss = true
      end

      app.assets.register_engine '.mustache', LinearPerspective::MustacheCompiler
      app.config.assets.paths << LinearPerspective.template_path

      # TODO: probably bail if we're not in rails3/sprockets land...
      # TODO: probably cache asset version in prod?
      ActionController::Base.send(:include, LinearPerspective::ControllerAdditions)
    end
  end
end
