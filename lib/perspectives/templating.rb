module Perspectives
  module Templating
    def self.included(base)
      base.class_eval do
        extend ClassMethods

        delegate :_mustache, :_template_key, to: 'self.class'
      end
    end

    module ClassMethods
      def _mustache
        return @_mustache if defined?(@_mustache)

        klass = self
        @_mustache = Class.new(Mustache) do
          self.template_name = klass.to_s.underscore
          self.raise_on_context_miss = Perspectives.raise_on_context_miss?
        end
      end

      def _template_key
        @_template_key ||=
          _mustache.template_file.
            sub(/^#{Regexp.escape(_mustache.template_path)}\//, '').
            chomp(".#{_mustache.template_extension}")
      end
    end
  end
end
