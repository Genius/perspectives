class Perspectives::Forms::Base < Perspectives::Base
  def self.template_path
    File.expand_path('../../../../vendor/assets/javascripts', __FILE__)
  end
end
