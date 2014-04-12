module Perspectives
  class Responder < ActionController::Responder
    def to_html
      return super unless controller.__send__(:perspectives_enabled_action?)

      render text: resource.to_html, layout: :default
    end

    def to_json
      return super unless controller.__send__(:perspectives_enabled_action?)

      render json: resource
    end
  end
end
