module Perspectives
  module ControllerAdditions
    def self.included(base)
      base.before_filter :set_perspectives_version
      base.helper_method :assets_meta_tag
      base.class_attribute :perspectives_enabled_actions
      delegate :perspectives_enabled_actions, to: 'self.class'
      base.helper_method :perspective

      base.class_attribute :perspectives_wrapping
      base.perspectives_wrapping = []

      base.extend(ClassMethods)

      delegate 'resolve_perspective_class_name', to: 'self.class'
    end

    private

    unless defined?(ActionController::Responder)
      def respond_to(*mimes, &block)
        return super if block_given? || mimes.many? || !mimes.first.is_a?(Perspectives::Base)

        perspectives_object = mimes.first
        perspectives_object = wrap_perspective(perspectives_object) if wrap_perspective?

        super() do |format|
          format.html { render text: perspectives_object.to_html, layout: :default }
          format.json { render json: perspectives_object }
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

      resolve_perspective_class_name(name).new(context, params)
    end

    def respond_with(*resources, &block)
      return super unless wrap_perspective? && resources.first.is_a?(Perspectives::Base)

      wrapped = wrap_perspective(resources.shift)

      super(*resources.unshift(wrapped), &block)
    end

    def default_context
      {}
    end

    def assets_version
      Rails.application.assets.index.each_file.to_a.map { |f| File.new(f).mtime }.max.to_i
    end

    def assets_meta_tag
      view_context.content_tag(:meta, nil, :'http-equiv' => 'x-perspectives-version', content: assets_version)
    end

    def set_perspectives_version
      response.headers['X-Perspectives-Version'] = assets_version.to_s
    end

    def perspectives_enabled_action?
      action_enabled_by?(perspectives_enabled_actions)
    end

    def perspectives_wrapper
      return unless perspectives_enabled_action? && (request.headers['X-Perspectives-Full-Page'].to_s == 'true' || !request.xhr?)

      perspectives_wrapping.find do |_, options|
        next unless action_enabled_by?(options)

        if options[:unless].present?
          !options[:unless].call(self)
        elsif options[:if].present?
          options[:if].call(self)
        else
          true
        end
      end
    end
    alias_method :wrap_perspective?, :perspectives_wrapper

    def wrap_perspective(unwrapped_perspective)
      perspective_klass, options = *perspectives_wrapper
      perspective_klass.new(unwrapped_perspective.context, options[:args].call(self, unwrapped_perspective))
    end

    def action_enabled_by?(options)
      return false if options.nil?

      action = action_name.to_s

      if options[:except]
        !options[:except].include?(action)
      elsif options[:only]
        options[:only].include?(action)
      else
        true
      end
    end

    module ClassMethods
      def perspectives_actions(options = {})
        self.perspectives_enabled_actions = options.slice(:only, :except).each_with_object({}) do |(k, v), h|
          h[k] = Array(v).map(&:to_s)
        end

        respond_to :html, :json, options
        self.responder = Perspectives::Responder
      end

      def wrapped_with(perspective, options = {})
        perspective_klass = resolve_perspective_class_name(perspective)

        options[:only] = Array(options[:only]).map(&:to_s) if options[:only]
        options[:except] = Array(options[:except]).map(&:to_s) if options[:except]

        options[:if] ||= lambda { |c| c.params[perspective_klass.id_param].present? }
        options[:args] ||= lambda do |controller, perspective|
          {
            perspective_klass.active_record_klass.name.underscore => perspective_klass.active_record_klass.find(controller.params[perspective_klass.id_param]),
            options.fetch(:as, controller_name.underscore.singularize) => perspective
          }
        end

        self.perspectives_wrapping += [[perspective_klass, options]]
      end

      def resolve_perspective_class_name(name)
        Perspectives.resolve_partial_class_name(controller_name.camelize, name)
      end
    end
  end
end
