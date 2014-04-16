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
    end

    private

    unless defined?(ActionController::Responder)
      def respond_to(*mimes, &block)
        return super if block_given? || mimes.many? || !mimes.first.is_a?(Perspectives::Base)

        perspectives_object = mimes.first

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

      Perspectives.resolve_partial_class_name(controller_name.camelize, name).new(context, params)
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

    def respond_with(perspective)
      # TODO - respond_to equivalent
      return super if !perspectives_enabled_action? || request.xhr?

      wrapper = perspectives_wrapping.find do |perspective, options|
        next unless action_enabled_by?(options)

        if options[:unless].present?
          !options[:unless].call(self)
        elsif options[:if].present?
          options[:if].call(self)
        else
          true
        end
      end

      return super unless wrapper

      perspective_name, options = *wrapper
      args = options.fetch(:args) || proc { |*| {} }

      super(perspective(perspective_name, args.call(self, perspective)))
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
        options[:only] = Array(options[:only]).map(&:to_s) if options[:only]
        options[:except] = Array(options[:except]).map(&:to_s) if options[:except]

        self.perspectives_wrapping += [[perspective, options]]
      end
    end
  end
end
