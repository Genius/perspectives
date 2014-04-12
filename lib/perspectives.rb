require 'forwardable'
require 'mustache'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/module/delegation'
require 'perspectives/collection'
require 'perspectives/base'
require 'perspectives/configuration'
require 'perspectives/mustache_compiler'
require 'perspectives/railtie' if defined?(Rails) # TODO: older rails support!

module Perspectives
  class << self
    def template_namespace
      'LP'
    end

    def configure
      yield(configuration)
    end

    delegate :cache, :caching?, :template_path, :raise_on_context_miss?, to: :configuration
    delegate :expand_cache_key, to: 'ActiveSupport::Cache'

    def resolve_partial_class_name(top_level_view_namespace, name)
      camelized = name.to_s.camelize

      [top_level_view_namespace, camelized].join('::').constantize
    rescue NameError
      camelized.constantize
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end
  end

  configure do |c|
    c.raise_on_context_miss = true
  end
end
