module Perspectives
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def id_param
        :"#{active_record_klass.name.underscore}_id"
      end

      def active_record_klass
        name.split('::').first.singularize.constantize
      end
    end
  end
end
