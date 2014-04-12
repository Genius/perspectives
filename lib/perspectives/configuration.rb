module Perspectives
  class Configuration
    delegate :template_path, :template_path=, :raise_on_context_miss?, :raise_on_context_miss, :raise_on_context_miss=, to: 'Mustache'

    CacheNotConfigured = Class.new(StandardError)
    attr_writer :cache
    attr_accessor :caching
    alias_method :caching?, :caching

    def cache
      @cache || (raise CacheNotConfigured, "You must configure a cache")
    end
  end
end
