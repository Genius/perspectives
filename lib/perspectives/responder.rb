module Perspectives
  class Responder < ActionController::Responder
    def to_html
      return super unless resource.is_a?(Perspectives::Base)

      render text: resource.to_html, layout: :default
    end

    def to_json
      return super unless resource.is_a?(Perspectives::Base)

      render json: resource
    end
  end
end
