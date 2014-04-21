module Perspectives
  module Caching
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        class_attribute :_cache_key_additions_block
        delegate :_class_source_digest, :_mustache_source_digest, to: 'self.class'
      end
    end

    def render_html
      _with_cache('html') { super }
    end

    def to_json(options = {})
      _with_cache('json') { super }
    end

    private

    def _cache
      Perspectives.cache
    end

    def _expand_cache_key(*args, &block)
      Perspectives.expand_cache_key(*args, &block)
    end

    def _with_cache(*key_additions)
      return yield unless _caching?

      _cache.fetch(_expand_cache_key(_cache_key.concat(key_additions))) { yield }
    end

    def _cache_key
      return [] unless _caching?

      [].tap do |key|
        key << self.class.to_s
        key << _mustache_source_digest
        key << _class_source_digest
        key.concat(Array(instance_eval(&_cache_key_additions_block))) if _cache_key_additions_block
        key.concat _dependent_cache_keys
      end
    end

    def _caching?
      Perspectives.caching? && !!_cache_key_additions_block
    end

    def _dependent_cache_keys
      _nested_perspectives.each_with_object([]) do |property_name, key|
        perspectives = __send__(property_name)

        case perspectives
        when NilClass
        when Array
          key.concat(perspectives.map { |p| p.__send__(:_cache_key) }.flatten)
        else
          key.concat(perspectives.__send__(:_cache_key))
        end
      end
    end

    module ClassMethods
      def cache(&block)
        raise ArgumentError, "No block given" unless block_given?

        self._cache_key_additions_block = block
      end

      def _class_source_digest
        @_class_source_digest ||= Digest::MD5.hexdigest(File.read(filename))
      end

      def _mustache_source_digest
        @_mustache_source_digest ||= Digest::MD5.hexdigest(_mustache.template.source)
      end
    end
  end
end
