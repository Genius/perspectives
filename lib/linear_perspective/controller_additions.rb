module LinearPerspective
  module ControllerAdditions
    def self.included(base)
      base.before_filter :set_perspective_version
      base.helper_method :assets_meta_tag

      base.extend(ClassMethods)
    end

    private

    unless defined?(ActionController::Responder)
      def respond_to(*mimes, &block)
        return super if block_given? || mimes.many? || !mimes.first.is_a?(LinearPerspective::Base)

        perspective_object = mimes.first

        super() do |format|
          format.html { render text: perspective_object.to_html, layout: :default }
          format.json { render json: perspective_object }
        end
      end
    end

    def perspective(name, params_or_options = {})
      if params_or_options.key?(:context) || params_or_options.key?(:params)
        params = params_or_options.fetch(:params, {})
        context = params_or_options.fetch(:context, default_context)
      else
        context = default_context
        params = params_or_options
      end

      LinearPerspective.resolve_partial_class_name(controller_name.camelize, name).new(context, params)
    end

    def default_context
      {}
    end

    def assets_version
      Rails.application.assets.index.each_file.to_a.map { |f| File.new(f).mtime }.max.to_i
    end

    def assets_meta_tag
      view_context.content_tag(:meta, nil, :'http-equiv' => 'x-perspective-version', content: assets_version)
    end

    def set_perspective_version
      response.headers['X-Perspective-Version'] = assets_version.to_s
    end

    module ClassMethods
      # TODO: probably some kind of :only => [:foo] support
      def perspective_actions
        respond_to :html, :json
        self.responder = LinearPerspective::Responder
      end
    end
  end
end
