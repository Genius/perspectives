require 'rails/generators/resource_helpers'

module Perspectives
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      source_root File.expand_path("../templates", __FILE__)

      def create_root_folders
        empty_directory mustache_path
        empty_directory perspectives_path
      end

      def copy_view_files
        available_views.each do |view|
          template "#{view}.mustache", mustache_path("#{view}.mustache")
          template "#{view}.rb", perspectives_path("#{view}.rb")
        end
      end

      # hook_for :form_builder, :as => :scaffold

      # def copy_form_file
      #   filename = 'form.mustache'
      #   template filename, mustache_path(filename)
      # end

      protected

      def available_views
        %w(index tiny)
      end

      # def available_views
      #   %w(index edit show new tiny)
      # end

      def handler
        :perspectives
      end

      def mustache_path(filename = nil)
        File.join(*["app/mustaches", controller_file_path, filename].compact)
      end

      def perspectives_path(filename = nil)
        File.join(*["app/perspectives", controller_file_path, filename].compact)
      end
    end
  end
end
