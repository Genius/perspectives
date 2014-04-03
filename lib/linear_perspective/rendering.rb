module LinearPerspective
  module Rendering
    def as_json(options = {})
      _property_map.merge(_template_key: _template_key)
    end

    def render_html
      _mustache.render(_property_map).html_safe
    end

    def render; render_html; end
    def to_html; render_html; end
    def to_s; render_html; end
  end
end
