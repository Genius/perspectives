module Perspectives
  class Responder < ActionController::Responder
    def to_html
      render text: resource.to_html, layout: :default
    end

    def to_json
      render json: resource
    end
  end
end
