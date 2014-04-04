require 'perspectives/controller_additions'
require 'perspectives/responder'

module Perspectives
  class Railtie < Rails::Railtie
    initializer 'perspectives.railtie' do |app|
      app.config.autoload_paths += ['app/perspectives']
      app.config.watchable_dirs['app/mustaches'] = [:mustache]

      app.config.assets.paths << File.expand_path('../../../vendor/assets/javascripts', __FILE__)

      Perspectives::Base.class_eval do
        include ActionView::Helpers
        include app.routes.url_helpers
        include ERB::Util
      end

      Perspectives.configure do |c|
        c.template_path = app.root.join('app', 'mustaches')
      end

      app.assets.register_engine '.mustache', Perspectives::MustacheCompiler
      app.config.assets.paths << Perspectives.template_path

      # TODO: probably bail if we're not in rails3/sprockets land...
      # TODO: probably cache asset version in prod?
      ActionController::Base.send(:include, Perspectives::ControllerAdditions)
    end
  end
end
