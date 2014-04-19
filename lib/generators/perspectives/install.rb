require 'rails/generators'

module Perspectives
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      source_root File.expand_path("../templates", __FILE__)
      desc "Installs Perspectives to Asset Pipeline"

      def add_assets
        js_manifest = 'app/assets/javascripts/application.js'

        if File.exist?(js_manifest)
          requirements = %w(mustache-0.8.1 perspectives ../../mustaches).map { |r| "//= require #{r}" }.join("\n")

          insert_into_file js_manifest, "#{requirements}\n", :after => "jquery_ujs\n"
        else
          copy_file "application.js", js_manifest
        end
      end
    end
  end
end

