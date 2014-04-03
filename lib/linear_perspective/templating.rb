module LinearPerspective
  module Templating
    def self.included(base)

      base.class_eval do
        extend ClassMethods

        def_delegators 'self.class', :_mustache, :_template_key
      end
    end

    module ClassMethods
      def _mustache
        return @_mustache if defined?(@_mustache)

        klass = self
        @_mustache = Class.new(Mustache) do
          self.template_name = klass.to_s.underscore
        end
      end

      private

      def _template_key
        @_template_key ||=
          _mustache.template_file.
            sub(/^#{_mustache.template_path}\//, '').
            chomp(".#{_mustache.template_extension}")
      end
    end
  end
end
