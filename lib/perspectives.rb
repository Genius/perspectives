require 'forwardable'
require 'mustache'
require 'active_support/core_ext/string/inflections'
require 'perspectives/base'
require 'perspectives/configuration'
require 'perspectives/mustache_compiler'
require 'perspectives/railtie' if defined?(Rails) # TODO: older rails support!

module Perspectives
  class << self
    extend Forwardable

    def template_namespace
      'LP'
    end

    def configure
      yield(configuration)
    end

    def_delegators :configuration, :cache, :caching?, :template_path
    def_delegator 'ActiveSupport::Cache', :expand_cache_key

    def resolve_partial_class_name(top_level_view_namespace, name)
      classified = name.to_s.classify

      [top_level_view_namespace, classified].join('::').constantize
    rescue NameError
      classified.constantize
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
